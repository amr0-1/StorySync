import 'package:storysync/features/library/data/models/reading_log.dart';

/// Reading rhythm classification (priority-ordered for personality).
enum ReadingRhythm {
  bingeKing,       // 50+ chapters in a single day at least once
  weekendWarrior,  // ≥60% of activity on Sat/Sun
  consistentTracker, // Streak ≥ 7 or activity spread ≥ 5 days/week
  comebackKid,     // Streak broken and resumed within 3 days
  casualDrifter,   // < 3 active days/week
  avidReader;      // Fallback

  String get displayTitle => switch (this) {
    ReadingRhythm.bingeKing => 'The Binge King',
    ReadingRhythm.weekendWarrior => 'Weekend Warrior',
    ReadingRhythm.consistentTracker => 'Consistent Tracker',
    ReadingRhythm.comebackKid => 'The Comeback Kid',
    ReadingRhythm.casualDrifter => 'Casual Drifter',
    ReadingRhythm.avidReader => 'Avid Reader',
  };

  String get displaySubtitle => switch (this) {
    ReadingRhythm.bingeKing => 'You devour chapters like there\'s no tomorrow',
    ReadingRhythm.weekendWarrior => 'Weekends are your reading sanctuary',
    ReadingRhythm.consistentTracker => 'Steady and relentless, day after day',
    ReadingRhythm.comebackKid => 'You always find your way back',
    ReadingRhythm.casualDrifter => 'Reading at your own pace',
    ReadingRhythm.avidReader => 'A true lover of stories',
  };
}

/// Velocity trend direction.
enum TrendDirection { up, stable, down }

/// Consecutive-day reading streak data.
class StreakData {
  final int current;
  final int longest;

  const StreakData({required this.current, required this.longest});

  static const empty = StreakData(current: 0, longest: 0);
}

/// Chapters-read comparison: last 7 days vs previous 7 days.
class VelocityTrend {
  final int last7;
  final int prev7;
  final double ratio; // (last7 - prev7) / max(prev7, 1)
  final TrendDirection direction;

  const VelocityTrend({
    required this.last7,
    required this.prev7,
    required this.ratio,
    required this.direction,
  });

  static const empty = VelocityTrend(
    last7: 0,
    prev7: 0,
    ratio: 0,
    direction: TrendDirection.stable,
  );

  String get displayText {
    if (last7 == 0 && prev7 == 0) return 'No recent activity';
    return switch (direction) {
      TrendDirection.up => '↑ $_multiplierText more than last week',
      TrendDirection.stable => '→ Steady pace this week',
      TrendDirection.down => '↓ Slowed down from last week',
    };
  }

  String get _multiplierText {
    if (prev7 == 0) return '$last7 chapters';
    final mult = last7 / prev7;
    if (mult >= 2) return '${mult.toStringAsFixed(1)}x';
    return '${(ratio * 100).round()}%';
  }
}

/// Analytics for a specific manga title.
class TitleStat {
  final String mangaDexId;
  final String title;
  final int totalChapters;
  final DateTime lastActivity;

  const TitleStat({
    required this.mangaDexId,
    required this.title,
    required this.totalChapters,
    required this.lastActivity,
  });
}

/// Aggregated title analytics.
class TitleAnalytics {
  final List<TitleStat> topSeries;   // Top 3 most consumed
  final List<TitleStat> coldSeries;  // >14 days no activity
  final List<TitleStat> hotSeries;   // >15 chapters in a 24h window

  const TitleAnalytics({
    required this.topSeries,
    required this.coldSeries,
    required this.hotSeries,
  });

  static const empty = TitleAnalytics(topSeries: [], coldSeries: [], hotSeries: []);
}

/// Detail data for a single tapped day on the heatmap.
class DayDetail {
  final DateTime date;
  final int totalChapters;
  final List<DayTitleEntry> titles;

  const DayDetail({
    required this.date,
    required this.totalChapters,
    required this.titles,
  });
}

/// A single title's reading data for a specific day.
class DayTitleEntry {
  final String mangaDexId;
  final String title;
  final int chaptersRead;

  const DayTitleEntry({
    required this.mangaDexId,
    required this.title,
    required this.chaptersRead,
  });
}

/// Pre-aggregated data structure to avoid repeated grouping.
class AggregatedLogs {
  final Map<DateTime, List<ReadingLog>> byDay;
  final Map<String, List<ReadingLog>> byTitle;
  final Map<DateTime, int> dailyTotals;

  const AggregatedLogs({
    required this.byDay,
    required this.byTitle,
    required this.dailyTotals,
  });
}

/// Top-level snapshot consumed by the Insights UI.
class AnalyticsSnapshot {
  final StreakData streaks;
  final ReadingRhythm rhythm;
  final VelocityTrend velocity;
  final TitleAnalytics titleAnalytics;
  final List<String> insights;
  final String personalityTitle;
  final String personalitySubtitle;
  final Map<DateTime, int> dailyTotals;
  final int librarySize;
  final int totalChaptersLogged;

  const AnalyticsSnapshot({
    required this.streaks,
    required this.rhythm,
    required this.velocity,
    required this.titleAnalytics,
    required this.insights,
    required this.personalityTitle,
    required this.personalitySubtitle,
    required this.dailyTotals,
    required this.librarySize,
    required this.totalChaptersLogged,
  });
}
