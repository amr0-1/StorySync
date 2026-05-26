import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:storysync/core/notifications/notification_service.dart';
import 'package:storysync/features/analytics/services/analytics_cache_service.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/data/models/reading_log.dart';

/// Unique task name for the periodic streak check.
const String streakCheckTaskName = 'com.storysync.streakCheck';

/// Background worker entry point — Context-Aware Notifications 2.0.
///
/// This function runs in a separate isolate — it must NOT reference
/// any Flutter widgets, Riverpod providers, or UI-bound state.
///
/// **Phase 14 upgrade:**
/// Instead of opening Isar for analytics (memory-heavy), reads the
/// lightweight [CachedAnalytics] JSON from SharedPreferences for
/// context-aware scheduling and dynamic notification payloads.
///
/// Isar is still opened, but ONLY for the minimal query:
/// "Did the user read today?" (a single date-filtered count).
///
/// Logic:
/// 1. Read [CachedAnalytics] from SharedPreferences.
/// 2. Open Isar ONLY to check if any organic logs exist for today.
/// 3. Determine the optimal notification window from `peakHour`.
/// 4. If no reading today AND within the notification window:
///    → Show a context-aware notification with dynamic payload.
/// 5. If reading exists today → cancel any pending reminder.
@pragma('vm:entry-point')
void streakWorkerCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != streakCheckTaskName) return true;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // ── Step 1: Read the analytics cache ─────────────────────
      final cache = await AnalyticsCacheService.loadCachedAnalytics();

      // ── Step 2: Minimal Isar query — did the user read today? ─
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
        [MangaItemSchema, ReadingLogSchema],
        directory: dir.path,
        name: 'storysync_db',
      );

      final todayLogs = await isar.readingLogs
          .filter()
          .dateEqualTo(today)
          .findAll();

      final organicToday = todayLogs
          .where((log) => !log.isImported && !log.isPastReading)
          .toList();

      if (organicToday.isNotEmpty) {
        // User has read today — cancel any pending reminder and exit
        final notificationService = NotificationService();
        await notificationService.initialize();
        await notificationService.cancelStreakReminder();
        await isar.close();
        return true;
      }

      // ── Step 3: Determine notification window ────────────────
      // Use peak hour from analytics cache, fallback to 20 (8 PM).
      final peakHour = cache?.peakHour ?? 20;

      // Notify 15 minutes before peak hour.
      // The worker runs approximately every hour, so we check if
      // the current hour is within the notification window.
      final notifyHour = peakHour > 0 ? peakHour - 1 : 23;
      final inWindow = now.hour >= notifyHour && now.hour <= peakHour;

      if (!inWindow) {
        // Not time yet — skip this cycle
        await isar.close();
        return true;
      }

      // ── Step 4: Check streak eligibility ─────────────────────
      // Only notify if the user was active yesterday (streak at risk)
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayLogs = await isar.readingLogs
          .filter()
          .dateEqualTo(yesterday)
          .findAll();
      final organicYesterday = yesterdayLogs
          .where((log) => !log.isImported && !log.isPastReading)
          .toList();

      await isar.close();

      if (organicYesterday.isEmpty) {
        // No streak to protect — don't bother the user
        return true;
      }

      // ── Step 5: Build context-aware notification ─────────────
      final payload = _buildPayload(cache);

      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.showStreakReminder(
        title: payload.title,
        body: payload.body,
      );
    } catch (_) {
      // Silently fail — background tasks should not crash
      return false;
    }

    return true;
  });
}

/// Build a dynamic notification payload based on cached analytics state.
///
/// Priority-ordered contextual messages:
/// 1. **Drop-off Risk** — "Continue [Series Name]?"
/// 2. **Fatigue** — "Take it easy today."
/// 3. **Default** — "Don't break your [X]-day streak!"
_NotificationPayload _buildPayload(CachedAnalytics? cache) {
  if (cache == null) {
    return const _NotificationPayload(
      title: 'Your streak is at risk! 📖',
      body:
          'You haven\'t read anything today. Open StorySync to keep your streak alive!',
    );
  }

  // ── Priority 1: Drop-off Risk ─────────────────────────────
  if (cache.dropOffRiskTitles.isNotEmpty) {
    final series = cache.dropOffRiskTitles.first;
    return _NotificationPayload(
      title: 'Missing $series? 📚',
      body:
          'You usually come back after a break. Continue reading $series?',
    );
  }

  // ── Priority 2: Fatigue Alert ─────────────────────────────
  if (cache.isFatigued) {
    return const _NotificationPayload(
      title: 'Take it easy today 🍃',
      body:
          'You\'ve been reading a lot lately. Maybe try a shorter series or just one chapter?',
    );
  }

  // ── Priority 3: Default — Streak Protection ───────────────
  final streak = cache.currentStreak;
  final peakLabel = cache.peakHourLabel;

  if (streak > 0) {
    return _NotificationPayload(
      title: 'Don\'t break your $streak-day streak! 🔥',
      body:
          'Your peak reading time ($peakLabel) is coming up. Open StorySync to keep going!',
    );
  }

  return const _NotificationPayload(
    title: 'Time to read? 📖',
    body: 'Open StorySync and start a new chapter!',
  );
}

/// Registers the periodic streak check task with Workmanager.
///
/// Call this once during app initialization. The OS will schedule
/// the task to run approximately every hour (minimum guaranteed interval
/// on Android is ~15 minutes due to battery optimizations).
Future<void> registerStreakWorker() async {
  await Workmanager().initialize(
    streakWorkerCallbackDispatcher,
  );

  await Workmanager().registerPeriodicTask(
    streakCheckTaskName,
    streakCheckTaskName,
    frequency: const Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 15),
  );
}

/// Simple record for notification title + body.
class _NotificationPayload {
  final String title;
  final String body;
  const _NotificationPayload({required this.title, required this.body});
}
