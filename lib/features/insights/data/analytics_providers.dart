import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/features/insights/data/analytics_engine.dart';
import 'package:storysync/features/insights/data/analytics_models.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/data/models/reading_log.dart';

/// Provider for the analytics engine (stateless, constant).
final analyticsEngineProvider = Provider<AnalyticsEngine>((ref) {
  return const AnalyticsEngine();
});

class _ComputePayload {
  final List<ReadingLog> logs;
  final List<MangaItem> manga;
  const _ComputePayload(this.logs, this.manga);
}

Future<AnalyticsSnapshot> _computeSnapshot(_ComputePayload payload) async {
  const engine = AnalyticsEngine();

  // Pre-aggregate once (filters out isImported + isPastReading)
  final agg = engine.aggregate(payload.logs);

  // Compute all analytics from the shared aggregation
  final streaks = engine.calculateStreaks(agg);
  final rhythm = engine.detectRhythm(agg, streaks);
  final velocity = engine.calculateVelocity(agg);
  final titleAnalytics = engine.getTitleAnalytics(agg, payload.manga);
  final insights = engine.generateInsights(
    agg,
    streaks,
    velocity,
    titleAnalytics,
  );
  final (personalityTitle, personalitySubtitle) = engine.derivePersonality(
    rhythm,
  );

  final totalChapters = agg.dailyTotals.values.fold<int>(0, (a, b) => a + b);

  return AnalyticsSnapshot(
    streaks: streaks,
    rhythm: rhythm,
    velocity: velocity,
    titleAnalytics: titleAnalytics,
    insights: insights,
    personalityTitle: personalityTitle,
    personalitySubtitle: personalitySubtitle,
    dailyTotals: agg.dailyTotals,
    librarySize: payload.manga.length,
    totalChaptersLogged: totalChapters,
  );
}

/// The single source of truth for the Insights UI.
///
/// Uses [Rx.combineLatest2] to watch BOTH the ReadingLog collection
/// AND the MangaItem collection. Whenever either changes, the full
/// [AnalyticsSnapshot] is recomputed via an Isolate.
///
/// This fixes the reactivity bug where adding a new title required
/// an app restart to appear in the Insights heatmap.
final analyticsSnapshotProvider = StreamProvider<AnalyticsSnapshot>((ref) {
  final isarService = ref.watch(isarServiceProvider);

  // Combine both streams — fires when EITHER collection changes
  return Rx.combineLatest2<List<ReadingLog>, List<MangaItem>, _ComputePayload>(
    isarService.watchAllReadingLogs(),
    isarService.watchAllManga(),
    (logs, manga) => _ComputePayload(logs, manga),
  ).asyncMap((payload) async {
    return await compute(_computeSnapshot, payload);
  });
});

/// Provider for day-detail data (triggered by heatmap tap).
final dayDetailProvider = FutureProvider.family<DayDetail, DateTime>((
  ref,
  date,
) async {
  final isarService = ref.watch(isarServiceProvider);
  final engine = ref.watch(analyticsEngineProvider);

  final allLogs = await isarService.getAllReadingLogs();
  final allManga = await isarService.getAllManga();

  final agg = engine.aggregate(allLogs);
  final mangaMap = {for (final m in allManga) m.mangaDexId: m};

  return engine.getDayDetail(date, agg, mangaMap);
});

/// Provider to hold the currently selected heatmap day (null = none selected).
final selectedHeatmapDayProvider = StateProvider<DateTime?>((ref) => null);

/// Provider for the manga map (used by day detail bottom sheet).
final mangaMapProvider = FutureProvider<Map<String, MangaItem>>((ref) async {
  final isarService = ref.watch(isarServiceProvider);
  final allManga = await isarService.getAllManga();
  return {for (final m in allManga) m.mangaDexId: m};
});
