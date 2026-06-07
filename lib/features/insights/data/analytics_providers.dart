import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:isar/isar.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/features/insights/data/analytics_engine.dart';
import 'package:storysync/features/insights/data/analytics_models.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/data/models/reading_log.dart';
import 'package:storysync/core/providers/database_state_provider.dart';

/// Provider for the analytics engine (stateless, constant).
final analyticsEngineProvider = Provider<AnalyticsEngine>((ref) {
  return const AnalyticsEngine();
});

class _ComputePayload {
  final String dirPath;
  const _ComputePayload(this.dirPath);
}

Future<AnalyticsSnapshot> _computeSnapshot(_ComputePayload payload) async {
  var isar = Isar.getInstance('storysync_db');
  isar ??= await Isar.open(
    [MangaItemSchema, ReadingLogSchema],
    directory: payload.dirPath,
    name: 'storysync_db',
  );

  try {
    final logs = isar.readingLogs.where().findAllSync();
    final manga = isar.mangaItems.where().findAllSync();

    const engine = AnalyticsEngine();

    // Pre-aggregate once (filters out isImported + isPastReading)
    final agg = engine.aggregate(logs);

    // Compute all analytics from the shared aggregation
    final streaks = engine.calculateStreaks(agg);
    final rhythm = engine.detectRhythm(agg, streaks);
    final velocity = engine.calculateVelocity(agg);
    final titleAnalytics = engine.getTitleAnalytics(agg, manga);
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
      librarySize: manga.length,
      totalChaptersLogged: totalChapters,
    );
  } finally {
    // Dart GC will clean up the local pointer.
  }
}

/// The single source of truth for the Insights UI.
///
/// Uses [Rx.combineLatest2] to watch BOTH the ReadingLog collection
/// AND the MangaItem collection. Whenever either changes, the full
/// [AnalyticsSnapshot] is recomputed via an Isolate.
///
/// This fixes the reactivity bug where adding a new title required
/// an app restart to appear in the Insights heatmap.
final analyticsSnapshotProvider = StreamProvider<AnalyticsSnapshot>((ref) async* {
  final isarService = ref.watch(isarServiceProvider);
  final dirPath = await isarService.getDbDirectory();

  final stream = Rx.combineLatest2<void, void, _ComputePayload>(
    isarService.watchReadingLogChanges(),
    isarService.watchMangaChanges(),
    (_, _) => _ComputePayload(dirPath),
  )
  // Apply the exact same Brick Wall and Shock Absorber to the legacy engine
  .where((_) {
    final isRestoring = ref.read(isRestoringDatabaseProvider);
    return !isRestoring; 
  })
  .debounceTime(const Duration(milliseconds: 500))
  .asyncMap((payload) async {
    return await compute(_computeSnapshot, payload);
  });

  yield* stream;
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
