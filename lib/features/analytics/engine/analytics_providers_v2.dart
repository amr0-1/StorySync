import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:isar/isar.dart';

import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/features/analytics/engine/analytics_models_v2.dart';
import 'package:storysync/features/analytics/engine/predictive_engine.dart';
import 'package:storysync/features/analytics/engine/reading_dna_provider.dart';
import 'package:storysync/features/analytics/engine/session_analyzer.dart';
import 'package:storysync/features/insights/data/analytics_engine.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/data/models/reading_log.dart';
import 'package:storysync/core/providers/database_state_provider.dart';

// ════════════════════════════════════════════════════════════════════
// Isolate-safe payload & computation
// ════════════════════════════════════════════════════════════════════

/// Payload only carries the directory path. The Isolate fetches its own data.
class _V2ComputePayload {
  final String dirPath;
  const _V2ComputePayload(this.dirPath);
}

/// Top-level function executed inside `compute()`.
Future<AnalyticsSnapshotV2> _computeV2Snapshot(
  _V2ComputePayload payload,
) async {
  // 1. Open Isar safely inside the background thread
  var isar = Isar.getInstance('storysync_db');
  isar ??= await Isar.open(
    [MangaItemSchema, ReadingLogSchema],
    directory: payload.dirPath,
    name: 'storysync_db',
  );

  try {
    // 2. Fetch the massive lists ENTIRELY off the main thread
    final logs = isar.readingLogs.where().findAllSync();
    final manga = isar.mangaItems.where().findAllSync();

    // 3. Aggregate and Compute
    final agg = _aggregateV2(logs);
    const existingEngine = AnalyticsEngine();
    final legacyAgg = existingEngine.aggregate(logs);
    final streaks = existingEngine.calculateStreaks(legacyAgg);

    const dnaEngine = ReadingDnaEngine();
    final dna = dnaEngine.buildProfile(agg, streaks);

    const predictiveEngine = PredictiveEngine();
    final predictive = predictiveEngine.analyze(agg, manga);

    const sessionAnalyzer = SessionAnalyzer();
    final rawState = sessionAnalyzer.analyze(agg);

    final userState = UserState(
      fatigue: rawState.fatigue,
      mood: rawState.mood,
      efficiencyScore: dna.efficiency.overall,
      stateLabel: rawState.stateLabel,
    );

    return AnalyticsSnapshotV2(
      dna: dna,
      predictive: predictive,
      userState: userState,
      hourlyDistribution: agg.hourlyTotals,
      weekdayDistribution: agg.weekdayTotals,
      dailyTotals: agg.dailyTotals,
      currentStreak: streaks.current,
      longestStreak: streaks.longest,
    );
  } finally {
    // Detach isolate from native DB when done (do not close, just dereference)
    // Isar.getInstance instances shouldn't be forcefully closed if the main thread is using them,
    // but the Dart GC will clean up the local pointer.
  }
}

// ════════════════════════════════════════════════════════════════════
// V2 Aggregation (top-level for isolate access)
// ════════════════════════════════════════════════════════════════════

/// Aggregate raw reading logs into the V2 structure.
///
/// Extends the V1 aggregation with hour-of-day and day-of-week bucketing
/// derived from [ReadingLog.exactTimestamp].
///
/// Filters out non-organic logs (`isImported` / `isPastReading`).
AggregatedLogsV2 _aggregateV2(List<ReadingLog> rawLogs) {
  final logs =
      rawLogs.where((log) => !log.isImported && !log.isPastReading).toList();

  final byDay = <DateTime, List<ReadingLog>>{};
  final byTitle = <String, List<ReadingLog>>{};
  final dailyTotals = <DateTime, int>{};
  final hourlyTotals = <int, int>{};
  final weekdayTotals = <int, int>{};
  final hourlyLogCount = <int, int>{};
  final weekdayLogCount = <int, int>{};

  for (final log in logs) {
    final normalizedDate =
        DateTime(log.date.year, log.date.month, log.date.day);

    // Extract hour from exactTimestamp (falls back to noon for legacy logs)
    final hour = log.exactTimestamp?.hour ?? 12;
    final weekday = normalizedDate.weekday; // 1=Mon … 7=Sun

    // ── Group by day ───────────────────────────────────────────
    byDay.putIfAbsent(normalizedDate, () => []).add(log);
    dailyTotals[normalizedDate] =
        (dailyTotals[normalizedDate] ?? 0) + log.chaptersRead;

    // ── Group by title ─────────────────────────────────────────
    byTitle.putIfAbsent(log.mangaDexId, () => []).add(log);

    // ── Hour-of-day bucketing ──────────────────────────────────
    hourlyTotals[hour] = (hourlyTotals[hour] ?? 0) + log.chaptersRead;
    hourlyLogCount[hour] = (hourlyLogCount[hour] ?? 0) + 1;

    // ── Day-of-week bucketing ──────────────────────────────────
    weekdayTotals[weekday] =
        (weekdayTotals[weekday] ?? 0) + log.chaptersRead;
    weekdayLogCount[weekday] = (weekdayLogCount[weekday] ?? 0) + 1;
  }

  return AggregatedLogsV2(
    byDay: byDay,
    byTitle: byTitle,
    dailyTotals: dailyTotals,
    hourlyTotals: hourlyTotals,
    weekdayTotals: weekdayTotals,
    hourlyLogCount: hourlyLogCount,
    weekdayLogCount: weekdayLogCount,
  );
}

// ════════════════════════════════════════════════════════════════════
// Riverpod Providers
// ════════════════════════════════════════════════════════════════════

/// The single source of truth for Phase 14 analytics.
///
/// Uses [Rx.combineLatest2] to reactively watch BOTH the ReadingLog
/// and MangaItem Isar collections. Whenever either changes, the full
/// [AnalyticsSnapshotV2] is recomputed via a background isolate using
/// `compute()` — zero main-thread jank.
///
/// Usage:
/// ```dart
/// final snapshot = ref.watch(analyticsV2SnapshotProvider);
/// snapshot.when(
///   data: (data) => Text(data.dna.archetypeTitle),
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => Text('Error: $e'),
/// );
/// ```
final analyticsV2SnapshotProvider =
    StreamProvider<AnalyticsSnapshotV2>((ref) async* {
  final isarService = ref.watch(isarServiceProvider);
  final dirPath = await isarService.getDbDirectory();

  // Combine the lazy "doorbells" (Stream<void>)
  final stream = Rx.combineLatest2<void, void, _V2ComputePayload>(
    isarService.watchReadingLogChanges(),
    isarService.watchMangaChanges(),
    (_, _) => _V2ComputePayload(dirPath),
  )
  // The Brick Wall: Ignore triggers during a database restore
  .where((_) {
    final isRestoring = ref.read(isRestoringDatabaseProvider);
    return !isRestoring;
  })
  // The Shock Absorber: Wait for rapid micro-transactions to finish
  .debounceTime(const Duration(milliseconds: 500))
  .asyncMap((payload) async {
    // Spawn the isolate. Main thread does zero heavy lifting.
    return await compute(_computeV2Snapshot, payload);
  });

  yield* stream;
});

/// Convenience provider exposing just the [DnaProfile].
///
/// Useful when only the DNA archetype or efficiency score is needed
/// (e.g., adaptive theme, personality header).
final dnaProfileProvider = Provider<AsyncValue<DnaProfile>>((ref) {
  return ref.watch(analyticsV2SnapshotProvider).whenData((s) => s.dna);
});

/// Convenience provider exposing just the [UserState].
///
/// Consumed by the adaptive theme provider to determine palette variant.
final userStateProvider = Provider<AsyncValue<UserState>>((ref) {
  return ref.watch(analyticsV2SnapshotProvider).whenData((s) => s.userState);
});

/// Convenience provider exposing just the [PredictiveSnapshot].
///
/// Used by the smart insights feed and detail screens.
final predictiveSnapshotProvider =
    Provider<AsyncValue<PredictiveSnapshot>>((ref) {
  return ref
      .watch(analyticsV2SnapshotProvider)
      .whenData((s) => s.predictive);
});
