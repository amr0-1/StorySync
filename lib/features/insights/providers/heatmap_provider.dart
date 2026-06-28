import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/data/models/reading_log.dart';

// ════════════════════════════════════════════════════════════════════
// State: Selected Year
// ════════════════════════════════════════════════════════════════════

/// Holds the currently selected heatmap year.
///
/// Defaults to the current calendar year. Mutated by the year-selector
/// arrows in the Insights Hub.
final heatmapYearProvider = StateProvider<int>((ref) {
  return DateTime.now().year;
});

// ════════════════════════════════════════════════════════════════════
// Isolate Payload
// ════════════════════════════════════════════════════════════════════

class _HeatmapPayload {
  final String dirPath;
  final int year;

  const _HeatmapPayload({required this.dirPath, required this.year});
}

// ════════════════════════════════════════════════════════════════════
// Static Isolate Entry Point
// ════════════════════════════════════════════════════════════════════

/// Runs inside [compute] / [Isolate.run].
///
/// Opens its own Isar instance, queries ReadingLogs for the given year,
/// filters out non-organic logs (isImported / isPastReading), aggregates
/// into a daily totals map, and returns it.
///
/// **SYSTEM_BOUNDARIES §1:** Isolate boundary, returns Map (serialisable),
/// closes Isar in `finally`.
Future<Map<DateTime, int>> _computeYearlyHeatmap(
  _HeatmapPayload payload,
) async {
  Isar? isar;
  try {
    isar = Isar.getInstance('storysync_db');
    isar ??= await Isar.open(
      [MangaItemSchema, ReadingLogSchema],
      directory: payload.dirPath,
      name: 'storysync_db',
    );

    final yearStart = DateTime(payload.year, 1, 1);
    final yearEnd = DateTime(payload.year, 12, 31);

    final logs = isar.readingLogs
        .filter()
        .dateBetween(yearStart, yearEnd)
        .findAllSync();

    // Filter out non-organic logs (same convention as AnalyticsEngine.aggregate)
    final Map<DateTime, int> dailyTotals = {};
    for (final log in logs) {
      if (log.isImported || log.isPastReading) continue;

      final normalized = DateTime(log.date.year, log.date.month, log.date.day);
      dailyTotals[normalized] =
          (dailyTotals[normalized] ?? 0) + log.chaptersRead;
    }

    return dailyTotals;
  } catch (_) {
    return {};
  } finally {
    // §1: Background isolates must ALWAYS call isar.close() in finally.
    if (isar != null && isar.isOpen) {
      await isar.close();
    }
  }
}

// ════════════════════════════════════════════════════════════════════
// Yearly Heatmap Data Provider
// ════════════════════════════════════════════════════════════════════

/// Fetches heatmap daily totals for the year selected by
/// [heatmapYearProvider].
///
/// Runs the aggregation in a background isolate via [compute].
/// Automatically re-fetches when the selected year changes.
///
/// **SYSTEM_BOUNDARIES §2:** Dedicated provider — does not mutate
/// analytics_providers.dart.
final yearlyHeatmapProvider =
    FutureProvider<Map<DateTime, int>>((ref) async {
  final year = ref.watch(heatmapYearProvider);
  final isarService = ref.watch(isarServiceProvider);
  final dirPath = await isarService.getDbDirectory();

  final payload = _HeatmapPayload(dirPath: dirPath, year: year);
  return compute(_computeYearlyHeatmap, payload);
});
