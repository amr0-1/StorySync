import 'dart:math';

import 'package:storysync/features/analytics/engine/analytics_models_v2.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';

/// Pure computation engine for Predictive & Lifecycle Intelligence.
///
/// All methods are stateless — safe for `compute()` / `Isolate.run()`.
/// No Flutter, Riverpod, or Isar imports.
class PredictiveEngine {
  const PredictiveEngine();

  /// Run the full predictive analysis pipeline.
  PredictiveSnapshot analyze(
    AggregatedLogsV2 agg,
    List<MangaItem> manga,
  ) {
    final comebackPower = _calculateComebackPower(agg);
    final finishEstimates = _calculateFinishEstimates(agg, manga);
    final dropOffRisks = _detectDropOffRisks(agg, manga, comebackPower);
    final lifecycles = _analyzeLifecycles(agg, manga);

    return PredictiveSnapshot(
      finishEstimates: finishEstimates,
      dropOffRisks: dropOffRisks,
      comebackPower: comebackPower,
      seriesLifecycles: lifecycles,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Finish Estimate
  // ════════════════════════════════════════════════════════════════

  /// For each `ReadingStatus.reading` series with known `totalChapters`:
  /// `estimatedDays = remaining / rollingAvg(7d chapters for this series)`.
  List<FinishEstimate> _calculateFinishEstimates(
    AggregatedLogsV2 agg,
    List<MangaItem> manga,
  ) {
    final now = _normalizeDate(DateTime.now());
    final sevenAgo = now.subtract(const Duration(days: 7));
    final estimates = <FinishEstimate>[];

    for (final m in manga) {
      if (m.readingStatus != ReadingStatus.reading) continue;
      if (m.totalChapters == null || m.totalChapters == 0) continue;

      final remaining = m.totalChapters! - m.chapterProgress;
      if (remaining <= 0) continue;

      // Rolling 7-day average for THIS specific manga
      final titleLogs = agg.byTitle[m.mangaDexId] ?? [];
      int chaptersLast7 = 0;
      for (final log in titleLogs) {
        final d = _normalizeDate(log.date);
        if (!d.isBefore(sevenAgo)) {
          chaptersLast7 += log.chaptersRead;
        }
      }
      final rollingAvg = chaptersLast7 / 7.0;

      estimates.add(FinishEstimate(
        mangaDexId: m.mangaDexId,
        title: m.title,
        remainingChapters: remaining,
        rollingAvgPerDay: rollingAvg,
        estimatedDaysToFinish:
            rollingAvg > 0 ? (remaining / rollingAvg).ceil() : -1,
        isEstimable: rollingAvg > 0,
      ));
    }

    // Estimable first → then by estimated days ascending
    estimates.sort((a, b) {
      if (a.isEstimable && !b.isEstimable) return -1;
      if (!a.isEstimable && b.isEstimable) return 1;
      return a.estimatedDaysToFinish.compareTo(b.estimatedDaysToFinish);
    });

    return estimates;
  }

  // ════════════════════════════════════════════════════════════════
  // Comeback Power
  // ════════════════════════════════════════════════════════════════

  /// Calculate the average, median, and max gap (in days) between
  /// consecutive active reading days globally.
  ComebackPower _calculateComebackPower(AggregatedLogsV2 agg) {
    if (agg.byDay.length < 2) return ComebackPower.empty;

    final sortedDates = agg.byDay.keys.toList()..sort();
    final gaps = <int>[];

    for (int i = 1; i < sortedDates.length; i++) {
      final gap = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (gap > 0) gaps.add(gap);
    }

    if (gaps.isEmpty) return ComebackPower.empty;

    gaps.sort();
    final avg = gaps.fold<int>(0, (a, b) => a + b) / gaps.length;
    final median = gaps[gaps.length ~/ 2];
    final maxGap = gaps.last;

    return ComebackPower(
      averageGapDays: avg,
      medianGapDays: median,
      maxGapDays: maxGap,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Drop-off Risk
  // ════════════════════════════════════════════════════════════════

  /// Flag `ReadingStatus.reading` series where
  /// `daysSinceLastRead > userAverageComebackTime × 1.5`.
  ///
  /// Risk level is normalized: `daysSince / (threshold × 2)`, clamped 0–1.
  List<DropOffEntry> _detectDropOffRisks(
    AggregatedLogsV2 agg,
    List<MangaItem> manga,
    ComebackPower comebackPower,
  ) {
    final now = _normalizeDate(DateTime.now());
    // Minimum threshold of 3 days prevents false positives for new users
    final threshold = max(comebackPower.averageGapDays * 1.5, 3.0);
    final risks = <DropOffEntry>[];

    for (final m in manga) {
      if (m.readingStatus != ReadingStatus.reading) continue;

      // Determine last activity date for this series
      DateTime? lastActivity;

      // Prefer the persisted lastReadAt (Phase 14 field)
      if (m.lastReadAt != null) {
        lastActivity = _normalizeDate(m.lastReadAt!);
      } else {
        // Fallback: scan reading logs for the most recent entry
        final titleLogs = agg.byTitle[m.mangaDexId];
        if (titleLogs != null && titleLogs.isNotEmpty) {
          final sorted = titleLogs.toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          lastActivity = _normalizeDate(sorted.first.date);
        }
      }

      if (lastActivity == null) continue;

      final daysSince = now.difference(lastActivity).inDays;
      if (daysSince > threshold) {
        final riskLevel = (daysSince / (threshold * 2.0)).clamp(0.0, 1.0);
        risks.add(DropOffEntry(
          mangaDexId: m.mangaDexId,
          title: m.title,
          daysSinceLastRead: daysSince,
          riskLevel: riskLevel,
        ));
      }
    }

    // Highest risk first
    risks.sort((a, b) => b.riskLevel.compareTo(a.riskLevel));
    return risks;
  }

  // ════════════════════════════════════════════════════════════════
  // Series Lifecycle
  // ════════════════════════════════════════════════════════════════

  /// Map each series from first log → peak volume date → current phase.
  ///
  /// Outputs insights like "You lost interest after chapter X" via
  /// [dropOffChapter] on declining/dormant series.
  List<SeriesLifecycle> _analyzeLifecycles(
    AggregatedLogsV2 agg,
    List<MangaItem> manga,
  ) {
    final mangaMap = {for (final m in manga) m.mangaDexId: m};
    final lifecycles = <SeriesLifecycle>[];

    for (final entry in agg.byTitle.entries) {
      final m = mangaMap[entry.key];
      if (m == null) continue;

      final logs = entry.value;
      if (logs.isEmpty) continue;

      // Group logs by day for this series
      final dailyMap = <DateTime, int>{};
      for (final log in logs) {
        final d = _normalizeDate(log.date);
        dailyMap[d] = (dailyMap[d] ?? 0) + log.chaptersRead;
      }

      final sortedDays = dailyMap.keys.toList()..sort();
      final startDate = sortedDays.first;

      // ── Find peak day ────────────────────────────────────────
      DateTime peakDate = startDate;
      int peakVol = 0;
      for (final e in dailyMap.entries) {
        if (e.value > peakVol) {
          peakVol = e.value;
          peakDate = e.key;
        }
      }

      // ── Determine current lifecycle phase ────────────────────
      LifecyclePhase phase;

      if (m.readingStatus == ReadingStatus.completed) {
        phase = LifecyclePhase.completed;
      } else {
        final now = _normalizeDate(DateTime.now());
        final lastDay = sortedDays.last;
        final daysSinceLast = now.difference(lastDay).inDays;

        if (daysSinceLast > 14) {
          phase = LifecyclePhase.dormant;
        } else {
          // Compare recent 7-day avg to overall avg
          final totalChapters =
              dailyMap.values.fold<int>(0, (a, b) => a + b);
          final overallAvg = totalChapters / max(sortedDays.length, 1);

          final sevenAgo = now.subtract(const Duration(days: 7));
          int recentVol = 0;
          int recentDays = 0;
          for (final e in dailyMap.entries) {
            if (!e.key.isBefore(sevenAgo)) {
              recentVol += e.value;
              recentDays++;
            }
          }
          final recentAvg = recentDays > 0 ? recentVol / recentDays : 0.0;

          if (recentAvg > overallAvg * 1.2) {
            phase = LifecyclePhase.growing;
          } else if (recentAvg >= overallAvg * 0.8) {
            phase = LifecyclePhase.peak;
          } else {
            phase = LifecyclePhase.declining;
          }
        }
      }

      // ── Estimate drop-off chapter ────────────────────────────
      // Rough estimate: cumulative chapter count up to the peak day.
      int? dropOffChapter;
      if (phase == LifecyclePhase.declining ||
          phase == LifecyclePhase.dormant) {
        int cumulative = 0;
        for (final d in sortedDays) {
          cumulative += dailyMap[d]!;
          if (d == peakDate) {
            dropOffChapter = cumulative;
            break;
          }
        }
      }

      lifecycles.add(SeriesLifecycle(
        mangaDexId: entry.key,
        title: m.title,
        startDate: startDate,
        peakDate: peakDate,
        peakDailyVolume: peakVol,
        dropOffChapter: dropOffChapter,
        currentPhase: phase,
      ));
    }

    return lifecycles;
  }

  // ════════════════════════════════════════════════════════════════
  // Helpers
  // ════════════════════════════════════════════════════════════════

  static DateTime _normalizeDate(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
