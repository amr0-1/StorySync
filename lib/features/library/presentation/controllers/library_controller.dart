import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/core/native/widget_service.dart';
import 'package:storysync/core/providers/shared_prefs_provider.dart';
import 'package:storysync/features/insights/data/analytics_engine.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';

part 'library_controller.g.dart';

/// Types of smart alerts that can be triggered.
enum SmartAlertType { burnout, streakRecovery }

/// Controller for the Library feature.
///
/// Provides a reactive stream of manga items from the local Isar database
/// and exposes methods for CRUD operations.
@riverpod
class LibraryController extends _$LibraryController {
  IsarService get _isarService => ref.read(isarServiceProvider);
  WidgetService get _widgetService => ref.read(widgetServiceProvider);

  /// Session-scoped set of manga IDs where the 50+ chapter alert
  /// has been acknowledged. Prevents the dialog from re-triggering
  /// on every subsequent increment. Resets on app restart.
  final Set<String> _acknowledgedHighChapterAlerts = {};

  @override
  Stream<List<MangaItem>> build() {
    return _isarService.watchAllManga();
  }

  /// Adds a manga item to the library.
  ///
  /// If a manga with the same mangaDexId already exists, it will be updated.
  Future<void> addManga(MangaItem item) async {
    await _isarService.saveManga(item);
  }

  /// Updates an existing manga item in the library.
  ///
  /// This is an alias for [addManga] - due to the unique index on mangaDexId,
  /// saving a manga with an existing ID will update it.
  Future<void> updateManga(MangaItem item) async {
    await _isarService.saveManga(item);
  }

  /// Increments the chapter progress of a manga by 1.
  ///
  /// Returns `true` if successful, `false` if manga not found or at max.
  /// Returns `false` specifically when the 50+ chapter guard triggers
  /// to signal the UI to show the confirmation dialog.
  Future<bool> incrementChapter(
    String mangaDexId, {
    bool logToHeatmap = true,
  }) async {
    // Check if we should warn about high chapter count.
    // Skip if the user has already acknowledged for this title this session.
    if (logToHeatmap && !_acknowledgedHighChapterAlerts.contains(mangaDexId)) {
      final todayCount = await _isarService.getTodayChapterCount(mangaDexId);
      if (todayCount >= 50) {
        return false; // Signal that we need user confirmation
      }
    }

    final result = await _isarService.incrementChapter(
      mangaDexId,
      isPastReading: !logToHeatmap,
    );
    if (result) {
      // Fire and forget widget update to prevent blocking UI
      _widgetService.updateWidgetData().ignore();
    }
    return result;
  }

  /// Handles the 50+ chapter alert and saves based on user choice.
  ///
  /// Records the acknowledgment so subsequent increments bypass the
  /// 50+ guard for the remainder of this session.
  Future<bool> confirmAndIncrementChapter(
    String mangaDexId,
    bool isPastReading,
  ) async {
    // Mark as acknowledged — future increments skip the 50+ guard
    _acknowledgedHighChapterAlerts.add(mangaDexId);

    final result = await _isarService.incrementChapter(
      mangaDexId,
      isPastReading: isPastReading,
    );
    if (result) {
      _widgetService.updateWidgetData().ignore();
    }
    return result;
  }

  /// Checks today's chapter count for a manga.
  Future<int> getTodayChapterCount(String mangaDexId) async {
    return _isarService.getTodayChapterCount(mangaDexId);
  }

  /// Decrements the chapter progress of a manga by 1.
  ///
  /// Returns `true` if successful, `false` if manga not found or at 0.
  Future<bool> decrementChapter(String mangaDexId) async {
    return _isarService.decrementChapter(mangaDexId);
  }

  /// Updates the reading status of a manga.
  ///
  /// Returns `true` if successful, `false` if manga not found.
  Future<bool> updateStatus(String mangaDexId, ReadingStatus status) async {
    return _isarService.updateStatus(mangaDexId, status);
  }

  /// Removes a manga from the library (simple delete, no cascade).
  ///
  /// Returns `true` if successfully deleted, `false` if not found.
  Future<bool> removeManga(String mangaDexId) async {
    return _isarService.deleteManga(mangaDexId);
  }

  /// Returns the count of reading log entries for a given manga.
  ///
  /// Used by the delete guard dialog to check for orphaned logs.
  Future<int> getReadingLogCount(String mangaDexId) async {
    return _isarService.getReadingLogCountForManga(mangaDexId);
  }

  /// Moves a manga to the "Dropped" status, preserving all reading logs.
  ///
  /// Used as the safe alternative to deletion when logs exist.
  Future<bool> moveToDropped(String mangaDexId) async {
    return _isarService.updateStatus(mangaDexId, ReadingStatus.dropped);
  }

  /// Atomically deletes a manga AND all its associated reading logs.
  ///
  /// This is the "force delete" path — prevents orphaned logs.
  Future<bool> forceDeleteWithLogs(String mangaDexId) async {
    return _isarService.deleteMangaWithCascade(mangaDexId);
  }

  /// Checks if a manga exists in the library.
  Future<bool> exists(String mangaDexId) async {
    return _isarService.exists(mangaDexId);
  }

  /// Gets a single manga by its MangaDex ID.
  Future<MangaItem?> getManga(String mangaDexId) async {
    return _isarService.getMangaByMangaDexId(mangaDexId);
  }

  // ============================================================
  // Smart Alerts
  // ============================================================

  static const _burnoutAlertKey = 'alert_burnout_shown';
  static const _streakRecoveryKey = 'alert_streak_recovery_shown';

  /// Check for smart alerts. Returns alert type if one should be shown, null otherwise.
  /// Alerts are one-time triggers persisted via SharedPreferences.
  Future<SmartAlertType?> checkSmartAlerts() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final allLogs = await _isarService.getAllReadingLogs();
    const engine = AnalyticsEngine();
    final agg = engine.aggregate(allLogs);

    // Check burnout: >30 chapters/day for 4 consecutive days
    if (engine.detectBurnout(agg)) {
      final alreadyShown = prefs.getBool(_burnoutAlertKey) ?? false;
      if (!alreadyShown) {
        await prefs.setBool(_burnoutAlertKey, true);
        return SmartAlertType.burnout;
      }
    } else {
      // Reset if no longer in burnout state (allow re-trigger next time)
      await prefs.remove(_burnoutAlertKey);
    }

    // Check streak recovery: streak >7 was broken
    final streaks = engine.calculateStreaks(agg);
    if (engine.detectStreakBreak(agg, streaks)) {
      final lastShownKey =
          '${_streakRecoveryKey}_${DateTime.now().toIso8601String().substring(0, 10)}';
      final alreadyShown = prefs.getBool(lastShownKey) ?? false;
      if (!alreadyShown) {
        await prefs.setBool(lastShownKey, true);
        return SmartAlertType.streakRecovery;
      }
    }

    return null;
  }
}

/// StreamProvider that watches manga filtered by a specific reading status.
///
/// Usage:
/// ```dart
/// final readingManga = ref.watch(libraryByStatusProvider(ReadingStatus.reading));
/// ```
@riverpod
Stream<List<MangaItem>> libraryByStatus(
  LibraryByStatusRef ref,
  ReadingStatus status,
) {
  final isarService = ref.watch(isarServiceProvider);
  return isarService.watchMangaByStatus(status);
}

/// StreamProvider that watches a single manga by MangaDex ID.
final mangaByIdProvider = StreamProvider.family.autoDispose<MangaItem?, String>(
  (ref, mangaDexId) {
    final isarService = ref.watch(isarServiceProvider);
    return isarService.watchMangaByMangaDexId(mangaDexId);
  },
);
