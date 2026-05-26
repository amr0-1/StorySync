import 'dart:math';

import 'package:storysync/features/analytics/engine/analytics_models_v2.dart';
import 'package:storysync/features/insights/data/analytics_models.dart';

/// Pure computation engine for Reading DNA, Efficiency Scoring, and Habit Loops.
///
/// All methods are stateless and take pre-fetched, pre-aggregated data.
/// Safe for use inside `compute()` / `Isolate.run()` — no Flutter imports,
/// no Isar handles, no Riverpod references.
class ReadingDnaEngine {
  const ReadingDnaEngine();

  // ════════════════════════════════════════════════════════════════
  // Efficiency Score (0–100)
  // ════════════════════════════════════════════════════════════════

  /// Calculate the weighted Efficiency Score.
  ///
  /// Algorithm:
  /// - 40% → Streak consistency: `min(currentStreak / 7, 1.0) × 40`
  /// - 40% → Weekly volume: `min(last7DaysChapters / 20, 1.0) × 40`
  /// - 20% → Session focus: `(1 / avgTitlesPerActiveDay) × 20`
  EfficiencyScore calculateEfficiency(
    AggregatedLogsV2 agg,
    StreakData streaks,
  ) {
    // ── 40% — Streak consistency ───────────────────────────────
    final streakRaw = (streaks.current / 7.0).clamp(0.0, 1.0);
    final streakComponent = streakRaw * 40.0;

    // ── 40% — Weekly volume ────────────────────────────────────
    final now = _normalizeDate(DateTime.now());
    final sevenAgo = now.subtract(const Duration(days: 7));
    int last7 = 0;
    for (final entry in agg.dailyTotals.entries) {
      if (!entry.key.isBefore(sevenAgo)) last7 += entry.value;
    }
    final volumeRaw = (last7 / 20.0).clamp(0.0, 1.0);
    final volumeComponent = volumeRaw * 40.0;

    // ── 20% — Session focus ────────────────────────────────────
    // Measures how many distinct titles the user reads per active day.
    // 1 title/day = perfect focus (1.0), more titles = more fragmented.
    double focusRaw = 1.0;
    final recentDays =
        agg.byDay.entries.where((e) => !e.key.isBefore(sevenAgo)).toList();
    if (recentDays.isNotEmpty) {
      final totalTitlesAcrossDays = recentDays
          .map((e) => e.value.map((l) => l.mangaDexId).toSet().length)
          .fold<int>(0, (a, b) => a + b);
      final avgTitlesPerDay = totalTitlesAcrossDays / recentDays.length;
      focusRaw = (1.0 / max(avgTitlesPerDay, 1.0)).clamp(0.0, 1.0);
    }
    final focusComponent = focusRaw * 20.0;

    return EfficiencyScore(
      overall:
          (streakComponent + volumeComponent + focusComponent).clamp(0.0, 100.0),
      streakComponent: streakComponent,
      volumeComponent: volumeComponent,
      focusComponent: focusComponent,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // DNA Archetype Detection
  // ════════════════════════════════════════════════════════════════

  /// Detect the DNA Archetype from reading patterns.
  ///
  /// Priority-ordered (first match wins):
  /// 1. Night Owl — >80% of log entries fall in hours 21–02.
  /// 2. Binge-Oriented — stddev of daily volume > 2× mean.
  /// 3. Consistent Explorer — streak ≥ 7 with ≤ 5 chapters/day avg.
  /// 4. Morning Reader — >60% of log entries fall in hours 05–11.
  /// 5. Balanced Reader — fallback.
  DnaArchetype detectArchetype(
    AggregatedLogsV2 agg,
    StreakData streaks,
  ) {
    final totalLogs =
        agg.hourlyLogCount.values.fold<int>(0, (a, b) => a + b);

    // ── Priority 1: Night Owl ────────────────────────────────
    if (totalLogs > 0) {
      int nightLogs = 0;
      for (int h = 21; h <= 23; h++) {
        nightLogs += agg.hourlyLogCount[h] ?? 0;
      }
      for (int h = 0; h <= 2; h++) {
        nightLogs += agg.hourlyLogCount[h] ?? 0;
      }
      if (nightLogs / totalLogs > 0.8) return DnaArchetype.nightOwl;
    }

    // ── Priority 2: Binge-Oriented ───────────────────────────
    // Requires at least 3 active days to compute meaningful variance.
    if (agg.dailyTotals.length >= 3) {
      final values = agg.dailyTotals.values.toList();
      final mean = values.fold<int>(0, (a, b) => a + b) / values.length;
      if (mean > 0) {
        final variance = values
                .map((v) => (v - mean) * (v - mean))
                .fold<double>(0, (a, b) => a + b) /
            values.length;
        final stddev = sqrt(variance);
        if (stddev > 2.0 * mean) return DnaArchetype.bingeOriented;
      }
    }

    // ── Priority 3: Consistent Explorer ──────────────────────
    if (streaks.current >= 7) {
      final now = _normalizeDate(DateTime.now());
      final sevenAgo = now.subtract(const Duration(days: 7));
      int last7 = 0;
      int days7 = 0;
      for (final entry in agg.dailyTotals.entries) {
        if (!entry.key.isBefore(sevenAgo)) {
          last7 += entry.value;
          days7++;
        }
      }
      final avgPerDay = days7 > 0 ? last7 / days7 : 0.0;
      if (avgPerDay <= 5.0) return DnaArchetype.consistentExplorer;
    }

    // ── Priority 4: Morning Reader ───────────────────────────
    if (totalLogs > 0) {
      int morningLogs = 0;
      for (int h = 5; h <= 11; h++) {
        morningLogs += agg.hourlyLogCount[h] ?? 0;
      }
      if (morningLogs / totalLogs > 0.6) return DnaArchetype.morningReader;
    }

    // ── Fallback ─────────────────────────────────────────────
    return DnaArchetype.balancedReader;
  }

  // ════════════════════════════════════════════════════════════════
  // Habit Loop Detection
  // ════════════════════════════════════════════════════════════════

  /// Detect the user's Habit Loop — mode day-of-week and hour-of-day
  /// for reading activity spikes.
  HabitLoop detectHabitLoop(AggregatedLogsV2 agg) {
    // ── Mode day-of-week (by log frequency, not chapter count) ──
    int peakDay = 1;
    int peakDayCount = 0;
    for (final entry in agg.weekdayLogCount.entries) {
      if (entry.value > peakDayCount) {
        peakDayCount = entry.value;
        peakDay = entry.key;
      }
    }

    // ── Mode hour-of-day ────────────────────────────────────────
    int peakHour = 12;
    int peakHourCount = 0;
    for (final entry in agg.hourlyLogCount.entries) {
      if (entry.value > peakHourCount) {
        peakHourCount = entry.value;
        peakHour = entry.key;
      }
    }

    return HabitLoop(
      peakDayOfWeek: peakDay,
      peakHourOfDay: peakHour,
      peakDayLabel: _dayLabel(peakDay),
      peakHourLabel: _hourLabel(peakHour),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Composite Builder
  // ════════════════════════════════════════════════════════════════

  /// Build a complete [DnaProfile] from all sub-analyses.
  DnaProfile buildProfile(
    AggregatedLogsV2 agg,
    StreakData streaks,
  ) {
    final efficiency = calculateEfficiency(agg, streaks);
    final archetype = detectArchetype(agg, streaks);
    final habitLoop = detectHabitLoop(agg);

    return DnaProfile(
      efficiency: efficiency,
      archetype: archetype,
      habitLoop: habitLoop,
      archetypeTitle: archetype.displayTitle,
      archetypeSubtitle: archetype.displaySubtitle,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Helpers
  // ════════════════════════════════════════════════════════════════

  static DateTime _normalizeDate(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  static String _dayLabel(int weekday) => switch (weekday) {
        1 => 'Monday',
        2 => 'Tuesday',
        3 => 'Wednesday',
        4 => 'Thursday',
        5 => 'Friday',
        6 => 'Saturday',
        7 => 'Sunday',
        _ => 'Unknown',
      };

  static String _hourLabel(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}
