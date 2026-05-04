import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/data/models/reading_log.dart';
import 'package:storysync/features/insights/data/analytics_models.dart';

/// Pure computation service for reading analytics.
///
/// All methods take pre-fetched data as input — no direct database access.
/// This keeps computation off the main isolate boundary and makes testing trivial.
class AnalyticsEngine {
  const AnalyticsEngine();

  // ════════════════════════════════════════════════════════════════
  // Pre-Aggregation
  // ════════════════════════════════════════════════════════════════

  /// Pre-aggregate logs into day/title maps for reuse across all calculations.
  /// Filters out imported and past-reading logs.
  AggregatedLogs aggregate(List<ReadingLog> rawLogs) {
    // Filter out non-organic logs
    final logs = rawLogs
        .where((log) => !log.isImported && !log.isPastReading)
        .toList();

    final Map<DateTime, List<ReadingLog>> byDay = {};
    final Map<String, List<ReadingLog>> byTitle = {};
    final Map<DateTime, int> dailyTotals = {};

    for (final log in logs) {
      final normalizedDate = _normalizeDate(log.date);

      // Group by day
      byDay.putIfAbsent(normalizedDate, () => []).add(log);
      dailyTotals[normalizedDate] =
          (dailyTotals[normalizedDate] ?? 0) + log.chaptersRead;

      // Group by title
      byTitle.putIfAbsent(log.mangaDexId, () => []).add(log);
    }

    return AggregatedLogs(
      byDay: byDay,
      byTitle: byTitle,
      dailyTotals: dailyTotals,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Streaks
  // ════════════════════════════════════════════════════════════════

  /// Calculate current and longest consecutive-day reading streaks.
  StreakData calculateStreaks(AggregatedLogs agg) {
    if (agg.byDay.isEmpty) return StreakData.empty;

    final sortedDates = agg.byDay.keys.toList()..sort();
    final today = _normalizeDate(DateTime.now());

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;

    // Calculate longest streak
    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        tempStreak++;
      } else {
        if (tempStreak > longestStreak) longestStreak = tempStreak;
        tempStreak = 1;
      }
    }
    if (tempStreak > longestStreak) longestStreak = tempStreak;

    // Calculate current streak (must include today or yesterday)
    final lastDate = sortedDates.last;
    final daysSinceLast = today.difference(lastDate).inDays;

    if (daysSinceLast <= 1) {
      // Active streak — count backwards from the most recent date
      currentStreak = 1;
      for (int i = sortedDates.length - 2; i >= 0; i--) {
        final diff = sortedDates[i + 1].difference(sortedDates[i]).inDays;
        if (diff == 1) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    return StreakData(current: currentStreak, longest: longestStreak);
  }

  // ════════════════════════════════════════════════════════════════
  // Rhythm Detection
  // ════════════════════════════════════════════════════════════════

  /// Detect reading rhythm based on day-of-week patterns.
  ReadingRhythm detectRhythm(AggregatedLogs agg, StreakData streaks) {
    if (agg.byDay.isEmpty) return ReadingRhythm.avidReader;

    final now = _normalizeDate(DateTime.now());
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Get recent logs only (last 30 days) for pattern detection
    final recentDays = agg.byDay.entries
        .where((e) => e.key.isAfter(thirtyDaysAgo) || e.key == thirtyDaysAgo)
        .toList();

    if (recentDays.isEmpty) return ReadingRhythm.casualDrifter;

    // Priority 1: Binge King — any single day with 50+ chapters
    for (final entry in agg.dailyTotals.entries) {
      if (entry.value >= 50) return ReadingRhythm.bingeKing;
    }

    // Priority 2: Weekend Warrior — ≥60% of activity on Sat/Sun
    int weekendDays = 0;
    int totalDays = recentDays.length;
    for (final entry in recentDays) {
      final weekday = entry.key.weekday; // 6 = Saturday, 7 = Sunday
      if (weekday == 6 || weekday == 7) weekendDays++;
    }
    if (totalDays > 0 && weekendDays / totalDays >= 0.6) {
      return ReadingRhythm.weekendWarrior;
    }

    // Priority 3: Consistent Tracker — streak ≥ 7 or ≥ 5 distinct days/week
    if (streaks.current >= 7) return ReadingRhythm.consistentTracker;
    // Check distinct active days per week in the recent period
    final weeksActive = <int, Set<int>>{};
    for (final entry in recentDays) {
      final weekNumber = entry.key.difference(thirtyDaysAgo).inDays ~/ 7;
      weeksActive.putIfAbsent(weekNumber, () => {}).add(entry.key.weekday);
    }
    final avgDaysPerWeek = weeksActive.values.isEmpty
        ? 0.0
        : weeksActive.values.map((s) => s.length).reduce((a, b) => a + b) /
              weeksActive.values.length;
    if (avgDaysPerWeek >= 5) return ReadingRhythm.consistentTracker;

    // Priority 4: Comeback Kid — streak broken and resumed within 3 days
    final sortedDates = agg.byDay.keys.toList()..sort();
    for (int i = 1; i < sortedDates.length; i++) {
      final gap = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (gap > 1 && gap <= 3) {
        // Check if there was a streak before the gap
        if (i >= 7) {
          int priorStreak = 1;
          for (int j = i - 2; j >= 0; j--) {
            if (sortedDates[j + 1].difference(sortedDates[j]).inDays == 1) {
              priorStreak++;
            } else {
              break;
            }
          }
          if (priorStreak >= 7) return ReadingRhythm.comebackKid;
        }
      }
    }

    // Priority 5: Casual Drifter — < 3 active days/week
    if (avgDaysPerWeek < 3) return ReadingRhythm.casualDrifter;

    // Fallback
    return ReadingRhythm.avidReader;
  }

  // ════════════════════════════════════════════════════════════════
  // Velocity Trend
  // ════════════════════════════════════════════════════════════════

  /// Compare chapters read in last 7 days vs previous 7 days.
  VelocityTrend calculateVelocity(AggregatedLogs agg) {
    final now = _normalizeDate(DateTime.now());
    final sevenAgo = now.subtract(const Duration(days: 7));
    final fourteenAgo = now.subtract(const Duration(days: 14));

    int last7 = 0;
    int prev7 = 0;

    for (final entry in agg.dailyTotals.entries) {
      if (entry.key.isAfter(sevenAgo) || entry.key == sevenAgo) {
        last7 += entry.value;
      } else if (entry.key.isAfter(fourteenAgo) || entry.key == fourteenAgo) {
        prev7 += entry.value;
      }
    }

    // Relative comparison: avoids division by zero, avoids misleading spikes
    final ratio = (last7 - prev7) / (prev7 == 0 ? 1 : prev7).toDouble();

    final direction = ratio > 0.5
        ? TrendDirection.up
        : ratio < -0.5
        ? TrendDirection.down
        : TrendDirection.stable;

    return VelocityTrend(
      last7: last7,
      prev7: prev7,
      ratio: ratio,
      direction: direction,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Title Analytics
  // ════════════════════════════════════════════════════════════════

  /// Get top 3 most consumed series, cold/abandoned series (>14 days no activity),
  /// and hot/binge series (>15 chapters in a single day).
  TitleAnalytics getTitleAnalytics(AggregatedLogs agg, List<MangaItem> manga) {
    final now = _normalizeDate(DateTime.now());
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));
    final mangaMap = {for (final m in manga) m.mangaDexId: m};

    // Build title stats
    final List<TitleStat> allStats = [];
    // Track per-title daily max for binge detection
    final Map<String, int> titleDailyMax = {};

    for (final entry in agg.byTitle.entries) {
      final mangaItem = mangaMap[entry.key];
      if (mangaItem == null) continue;

      int total = 0;
      DateTime latest = DateTime(2000);
      int maxInOneDay = 0;

      // Group logs by day for this title
      final Map<DateTime, int> dailyForTitle = {};
      for (final log in entry.value) {
        total += log.chaptersRead;
        final normalized = _normalizeDate(log.date);
        if (normalized.isAfter(latest)) latest = normalized;
        dailyForTitle[normalized] =
            (dailyForTitle[normalized] ?? 0) + log.chaptersRead;
      }

      // Find the max single-day count for this title
      for (final dayTotal in dailyForTitle.values) {
        if (dayTotal > maxInOneDay) maxInOneDay = dayTotal;
      }
      titleDailyMax[entry.key] = maxInOneDay;

      allStats.add(
        TitleStat(
          mangaDexId: entry.key,
          title: mangaItem.title,
          totalChapters: total,
          lastActivity: latest,
        ),
      );
    }

    // Sort by total chapters (desc) for top 3
    allStats.sort((a, b) => b.totalChapters.compareTo(a.totalChapters));
    final top3 = allStats.take(3).toList();

    // Cold series: last activity >14 days ago
    final cold = allStats
        .where((s) => s.lastActivity.isBefore(fourteenDaysAgo))
        .toList();

    // Hot/Binge series: >15 chapters in a single day
    final hot = allStats
        .where((s) => (titleDailyMax[s.mangaDexId] ?? 0) > 15)
        .toList();

    return TitleAnalytics(topSeries: top3, coldSeries: cold, hotSeries: hot);
  }

  // ════════════════════════════════════════════════════════════════
  // Dynamic Insights
  // ════════════════════════════════════════════════════════════════

  /// Generate a pool of dynamic insight strings, deduplicated, returning top 6.
  List<String> generateInsights(
    AggregatedLogs agg,
    StreakData streaks,
    VelocityTrend velocity,
    TitleAnalytics titleAnalytics,
  ) {
    final Set<String> insights = {};

    // Streak insights
    if (streaks.current > 0) {
      insights.add('🔥 ${streaks.current}-day streak! Keep it going!');
    }
    if (streaks.longest > streaks.current && streaks.longest >= 5) {
      insights.add('🏆 Your record streak is ${streaks.longest} days');
    }

    // Velocity insights
    if (velocity.direction == TrendDirection.up && velocity.prev7 > 0) {
      final mult = velocity.last7 / velocity.prev7;
      if (mult >= 2) {
        insights.add(
          '📈 You read ${mult.toStringAsFixed(1)}x more than last week',
        );
      } else {
        insights.add('📈 Reading pace picked up from last week');
      }
    } else if (velocity.direction == TrendDirection.down &&
        velocity.prev7 > 0) {
      insights.add(
        '📉 Slowed down a bit — that\'s okay, quality over quantity',
      );
    }
    if (velocity.last7 > 0) {
      insights.add('📖 ${velocity.last7} chapters in the last 7 days');
    }

    // Binge day detection
    int maxDay = 0;
    DateTime? maxDate;
    for (final entry in agg.dailyTotals.entries) {
      if (entry.value > maxDay) {
        maxDay = entry.value;
        maxDate = entry.key;
      }
    }
    if (maxDay >= 20 && maxDate != null) {
      insights.add('⚡ You binged $maxDay chapters in one day!');
    }

    // Top series insight
    if (titleAnalytics.topSeries.isNotEmpty) {
      final top = titleAnalytics.topSeries.first;
      insights.add(
        '❤️ "${top.title}" is your most read (${top.totalChapters} ch.)',
      );
    }

    // Cold series insight
    if (titleAnalytics.coldSeries.isNotEmpty) {
      insights.add(
        '❄️ ${titleAnalytics.coldSeries.length} series idle for 14+ days',
      );
    }

    // Hot/Binge series insight
    if (titleAnalytics.hotSeries.isNotEmpty) {
      final hot = titleAnalytics.hotSeries.first;
      insights.add(
        '🔥 You binge-read "${hot.title}" — 15+ chapters in one day',
      );
    }

    // Total activity
    final totalChapters = agg.dailyTotals.values.fold<int>(0, (a, b) => a + b);
    if (totalChapters > 100) {
      insights.add('📚 Over $totalChapters chapters logged all-time');
    }

    // Active days
    final activeDays = agg.byDay.length;
    if (activeDays >= 30) {
      insights.add('📅 Active on $activeDays distinct days');
    }

    // Return top 6, prioritized by insertion order
    return insights.take(6).toList();
  }

  // ════════════════════════════════════════════════════════════════
  // Personality Derivation (Priority-Ordered)
  // ════════════════════════════════════════════════════════════════

  /// Derive reading personality from rhythm classification.
  (String title, String subtitle) derivePersonality(ReadingRhythm rhythm) {
    return (rhythm.displayTitle, rhythm.displaySubtitle);
  }

  // ════════════════════════════════════════════════════════════════
  // Day Detail (for bottom sheet)
  // ════════════════════════════════════════════════════════════════

  /// Get detailed data for a specific day.
  DayDetail getDayDetail(
    DateTime date,
    AggregatedLogs agg,
    Map<String, MangaItem> mangaMap,
  ) {
    final normalized = _normalizeDate(date);
    final logs = agg.byDay[normalized] ?? [];

    // Group by title, sorted by chapters desc then alphabetically
    final Map<String, int> titleChapters = {};
    for (final log in logs) {
      titleChapters[log.mangaDexId] =
          (titleChapters[log.mangaDexId] ?? 0) + log.chaptersRead;
    }

    final titles =
        titleChapters.entries.map((e) {
          final manga = mangaMap[e.key];
          return DayTitleEntry(
            mangaDexId: e.key,
            title: manga?.title ?? 'Unknown Title',
            chaptersRead: e.value,
          );
        }).toList()..sort((a, b) {
          final chapterCompare = b.chaptersRead.compareTo(a.chaptersRead);
          if (chapterCompare != 0) return chapterCompare;
          return a.title.compareTo(b.title);
        });

    final totalChapters = titleChapters.values.fold<int>(0, (a, b) => a + b);

    return DayDetail(
      date: normalized,
      totalChapters: totalChapters,
      titles: titles,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Burnout / Alert Detection
  // ════════════════════════════════════════════════════════════════

  /// Check if user has been reading heavily (>30 chapters/day for 4 consecutive days).
  bool detectBurnout(AggregatedLogs agg) {
    final now = _normalizeDate(DateTime.now());
    int consecutiveHeavyDays = 0;

    for (int i = 0; i < 4; i++) {
      final date = now.subtract(Duration(days: i));
      final total = agg.dailyTotals[date] ?? 0;
      if (total >= 30) {
        consecutiveHeavyDays++;
      } else {
        break;
      }
    }

    return consecutiveHeavyDays >= 4;
  }

  /// Check if a streak >7 was recently broken.
  bool detectStreakBreak(AggregatedLogs agg, StreakData streaks) {
    if (streaks.current > 0 || streaks.longest < 7) return false;

    final now = _normalizeDate(DateTime.now());
    final sortedDates = agg.byDay.keys.toList()..sort();
    if (sortedDates.isEmpty) return false;

    final lastDate = sortedDates.last;
    final daysSinceLast = now.difference(lastDate).inDays;

    // If user was away for 1-3 days and just came back today
    return daysSinceLast >= 1 && daysSinceLast <= 3;
  }

  // ════════════════════════════════════════════════════════════════
  // Helpers
  // ════════════════════════════════════════════════════════════════

  DateTime _normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
