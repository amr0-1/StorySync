import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/core/models/reading_state.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/presentation/controllers/library_controller.dart';

/// Computes [ReadingState] for each manga in the "Reading" tab.
///
/// Rules (Hot overrides Cold):
/// - **hot**: ≥ 15 chapters in last 24h OR ≥ 40 chapters in last 3 days
/// - **cold**: No organic activity for > 14 days
/// - **normal**: Default fallback
///
/// Returns `Map<String, ReadingState>` keyed by `mangaDexId`.
/// Invalidates when library data changes.
final readingStatesProvider = FutureProvider<Map<String, ReadingState>>((ref) async {
  // Watch library controller to auto-recompute when data changes
  final libraryAsync = ref.watch(libraryControllerProvider);

  final allManga = libraryAsync.valueOrNull ?? [];
  final readingManga = allManga.where(
    (m) => m.readingStatus == ReadingStatus.reading,
  );

  if (readingManga.isEmpty) return {};

  final isarService = ref.read(isarServiceProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final oneDayAgo = today.subtract(const Duration(days: 1));
  final threeDaysAgo = today.subtract(const Duration(days: 3));
  final fourteenDaysAgo = today.subtract(const Duration(days: 14));

  // Fetch all organic reading logs from the last 14 days in one batch
  final recentLogs = await isarService.getReadingLogsInRange(fourteenDaysAgo, today);

  // Pre-group by mangaDexId for efficient lookups
  final Map<String, List<_LogEntry>> logsByManga = {};
  for (final log in recentLogs) {
    if (log.isImported || log.isPastReading) continue;
    logsByManga.putIfAbsent(log.mangaDexId, () => []).add(
      _LogEntry(date: log.date, chapters: log.chaptersRead),
    );
  }

  final Map<String, ReadingState> result = {};

  for (final manga in readingManga) {
    final logs = logsByManga[manga.mangaDexId];

    if (logs == null || logs.isEmpty) {
      // No organic activity in 14 days → cold
      result[manga.mangaDexId] = ReadingState.cold;
      continue;
    }

    // Calculate chapters in last 24h
    int chaptersIn24h = 0;
    for (final log in logs) {
      final normalizedDate = DateTime(log.date.year, log.date.month, log.date.day);
      if (!normalizedDate.isBefore(oneDayAgo)) {
        chaptersIn24h += log.chapters;
      }
    }

    // Calculate chapters in last 3 days
    int chaptersIn3Days = 0;
    for (final log in logs) {
      final normalizedDate = DateTime(log.date.year, log.date.month, log.date.day);
      if (!normalizedDate.isBefore(threeDaysAgo)) {
        chaptersIn3Days += log.chapters;
      }
    }

    // Hot check (overrides cold)
    if (chaptersIn24h >= 15 || chaptersIn3Days >= 40) {
      result[manga.mangaDexId] = ReadingState.hot;
      continue;
    }

    // Cold check: most recent activity > 14 days ago
    DateTime? mostRecent;
    for (final log in logs) {
      final normalizedDate = DateTime(log.date.year, log.date.month, log.date.day);
      if (mostRecent == null || normalizedDate.isAfter(mostRecent)) {
        mostRecent = normalizedDate;
      }
    }

    if (mostRecent != null && mostRecent.isBefore(fourteenDaysAgo)) {
      result[manga.mangaDexId] = ReadingState.cold;
    } else {
      result[manga.mangaDexId] = ReadingState.normal;
    }
  }

  return result;
});

/// Internal helper to avoid pulling full ReadingLog model into the grouping logic.
class _LogEntry {
  final DateTime date;
  final int chapters;
  const _LogEntry({required this.date, required this.chapters});
}
