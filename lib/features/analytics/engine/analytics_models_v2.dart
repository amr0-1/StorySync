import 'package:storysync/features/library/data/models/reading_log.dart';

// ════════════════════════════════════════════════════════════════════
// Extended Aggregation (V2) — includes time-of-day bucketing
// ════════════════════════════════════════════════════════════════════

/// Pre-aggregated data structure that extends the original [AggregatedLogs]
/// with hour-of-day and day-of-week distributions derived from
/// [ReadingLog.exactTimestamp].
///
/// Built once per snapshot cycle, then shared across all three engines.
class AggregatedLogsV2 {
  /// Reading logs grouped by normalized date (midnight).
  final Map<DateTime, List<ReadingLog>> byDay;

  /// Reading logs grouped by manga title ID.
  final Map<String, List<ReadingLog>> byTitle;

  /// Total chapters read per day.
  final Map<DateTime, int> dailyTotals;

  /// Total chapters per hour-of-day (0–23).
  final Map<int, int> hourlyTotals;

  /// Total chapters per weekday (1=Mon … 7=Sun).
  final Map<int, int> weekdayTotals;

  /// Number of distinct log entries per hour (for frequency mode detection).
  final Map<int, int> hourlyLogCount;

  /// Number of distinct log entries per weekday.
  final Map<int, int> weekdayLogCount;

  const AggregatedLogsV2({
    required this.byDay,
    required this.byTitle,
    required this.dailyTotals,
    required this.hourlyTotals,
    required this.weekdayTotals,
    required this.hourlyLogCount,
    required this.weekdayLogCount,
  });

  static const empty = AggregatedLogsV2(
    byDay: {},
    byTitle: {},
    dailyTotals: {},
    hourlyTotals: {},
    weekdayTotals: {},
    hourlyLogCount: {},
    weekdayLogCount: {},
  );
}

// ════════════════════════════════════════════════════════════════════
// Feature Group A: Reading DNA & Scoring
// ════════════════════════════════════════════════════════════════════

/// Weighted efficiency score (0–100) combining streak, volume, and focus.
class EfficiencyScore {
  /// Composite score: streakComponent + volumeComponent + focusComponent.
  final double overall;

  /// 40% weight — (currentStreak / 7, capped at 1.0) × 40.
  final double streakComponent;

  /// 40% weight — (last 7 days chapters / 20 benchmark, capped at 1.0) × 40.
  final double volumeComponent;

  /// 20% weight — inverse of daily title fragmentation × 20.
  final double focusComponent;

  const EfficiencyScore({
    required this.overall,
    required this.streakComponent,
    required this.volumeComponent,
    required this.focusComponent,
  });

  static const empty = EfficiencyScore(
    overall: 0,
    streakComponent: 0,
    volumeComponent: 0,
    focusComponent: 0,
  );
}

/// DNA archetype derived from time-of-day patterns and reading variance.
///
/// Priority-ordered detection (first match wins):
/// 1. Night Owl → >80% activity 21:00–02:00
/// 2. Binge-Oriented → daily volume stddev > 2× mean
/// 3. Consistent Explorer → streak ≥ 7 with low daily volume
/// 4. Morning Reader → >60% activity 05:00–11:00
/// 5. Balanced Reader → fallback
enum DnaArchetype {
  nightOwl,
  bingeOriented,
  consistentExplorer,
  morningReader,
  balancedReader;

  String get displayTitle => switch (this) {
        DnaArchetype.nightOwl => 'Night Owl',
        DnaArchetype.bingeOriented => 'Binge Reader',
        DnaArchetype.consistentExplorer => 'Consistent Explorer',
        DnaArchetype.morningReader => 'Early Bird',
        DnaArchetype.balancedReader => 'Balanced Reader',
      };

  String get displaySubtitle => switch (this) {
        DnaArchetype.nightOwl => 'The chapters come alive after dark',
        DnaArchetype.bingeOriented => 'When you start, you can\'t stop',
        DnaArchetype.consistentExplorer =>
          'Slow and steady, never missing a day',
        DnaArchetype.morningReader => 'Pages before the world wakes up',
        DnaArchetype.balancedReader => 'A harmonious reading rhythm',
      };

  /// Emoji icon for compact display.
  String get icon => switch (this) {
        DnaArchetype.nightOwl => '🦉',
        DnaArchetype.bingeOriented => '⚡',
        DnaArchetype.consistentExplorer => '🧭',
        DnaArchetype.morningReader => '🌅',
        DnaArchetype.balancedReader => '⚖️',
      };
}

/// The user's peak reading time — mode day-of-week and hour-of-day.
class HabitLoop {
  /// 1 = Monday … 7 = Sunday.
  final int peakDayOfWeek;

  /// 0–23.
  final int peakHourOfDay;

  /// Human-readable: "Monday", "Saturday", etc.
  final String peakDayLabel;

  /// Human-readable: "10 PM", "2 AM", etc.
  final String peakHourLabel;

  const HabitLoop({
    required this.peakDayOfWeek,
    required this.peakHourOfDay,
    required this.peakDayLabel,
    required this.peakHourLabel,
  });

  static const empty = HabitLoop(
    peakDayOfWeek: 1,
    peakHourOfDay: 12,
    peakDayLabel: 'Monday',
    peakHourLabel: '12 PM',
  );
}

/// Complete DNA profile combining archetype, efficiency, and habit loop.
class DnaProfile {
  final EfficiencyScore efficiency;
  final DnaArchetype archetype;
  final HabitLoop habitLoop;

  /// Shortcut to [archetype.displayTitle].
  final String archetypeTitle;

  /// Shortcut to [archetype.displaySubtitle].
  final String archetypeSubtitle;

  const DnaProfile({
    required this.efficiency,
    required this.archetype,
    required this.habitLoop,
    required this.archetypeTitle,
    required this.archetypeSubtitle,
  });

  static final empty = DnaProfile(
    efficiency: EfficiencyScore.empty,
    archetype: DnaArchetype.balancedReader,
    habitLoop: HabitLoop.empty,
    archetypeTitle: DnaArchetype.balancedReader.displayTitle,
    archetypeSubtitle: DnaArchetype.balancedReader.displaySubtitle,
  );
}

// ════════════════════════════════════════════════════════════════════
// Feature Group B: Predictive & Lifecycle Intelligence
// ════════════════════════════════════════════════════════════════════

/// Per-series finish estimate based on 7-day rolling average.
class FinishEstimate {
  final String mangaDexId;
  final String title;
  final int remainingChapters;

  /// Average chapters/day for this series over the last 7 days.
  final double rollingAvgPerDay;

  /// Estimated days to finish. -1 if [isEstimable] is false.
  final int estimatedDaysToFinish;

  /// False when rolling average is 0 (no recent activity).
  final bool isEstimable;

  const FinishEstimate({
    required this.mangaDexId,
    required this.title,
    required this.remainingChapters,
    required this.rollingAvgPerDay,
    required this.estimatedDaysToFinish,
    required this.isEstimable,
  });
}

/// Series flagged for potential drop-off.
class DropOffEntry {
  final String mangaDexId;
  final String title;
  final int daysSinceLastRead;

  /// 0.0 (low) – 1.0 (high).
  final double riskLevel;

  const DropOffEntry({
    required this.mangaDexId,
    required this.title,
    required this.daysSinceLastRead,
    required this.riskLevel,
  });
}

/// Global measure of how quickly the user returns after a break.
class ComebackPower {
  /// Mean gap between consecutive active reading days.
  final double averageGapDays;

  /// Median gap — less sensitive to outliers.
  final int medianGapDays;

  /// Largest gap ever recorded.
  final int maxGapDays;

  const ComebackPower({
    required this.averageGapDays,
    required this.medianGapDays,
    required this.maxGapDays,
  });

  static const empty = ComebackPower(
    averageGapDays: 0,
    medianGapDays: 0,
    maxGapDays: 0,
  );
}

/// Lifecycle phase of a tracked series.
enum LifecyclePhase {
  growing,
  peak,
  declining,
  dormant,
  completed;

  String get displayLabel => switch (this) {
        LifecyclePhase.growing => 'Growing',
        LifecyclePhase.peak => 'At Peak',
        LifecyclePhase.declining => 'Declining',
        LifecyclePhase.dormant => 'Dormant',
        LifecyclePhase.completed => 'Completed',
      };

  String get icon => switch (this) {
        LifecyclePhase.growing => '📈',
        LifecyclePhase.peak => '🔥',
        LifecyclePhase.declining => '📉',
        LifecyclePhase.dormant => '💤',
        LifecyclePhase.completed => '✅',
      };
}

/// Lifecycle analysis for a single series.
class SeriesLifecycle {
  final String mangaDexId;
  final String title;
  final DateTime startDate;
  final DateTime peakDate;
  final int peakDailyVolume;

  /// Approximate chapter number where interest dropped. Null if still active.
  final int? dropOffChapter;

  final LifecyclePhase currentPhase;

  const SeriesLifecycle({
    required this.mangaDexId,
    required this.title,
    required this.startDate,
    required this.peakDate,
    required this.peakDailyVolume,
    this.dropOffChapter,
    required this.currentPhase,
  });
}

/// Combines all predictive analytics into a single snapshot.
class PredictiveSnapshot {
  final List<FinishEstimate> finishEstimates;
  final List<DropOffEntry> dropOffRisks;
  final ComebackPower comebackPower;
  final List<SeriesLifecycle> seriesLifecycles;

  const PredictiveSnapshot({
    required this.finishEstimates,
    required this.dropOffRisks,
    required this.comebackPower,
    required this.seriesLifecycles,
  });

  static const empty = PredictiveSnapshot(
    finishEstimates: [],
    dropOffRisks: [],
    comebackPower: ComebackPower.empty,
    seriesLifecycles: [],
  );
}

// ════════════════════════════════════════════════════════════════════
// Feature Group C: State & Mood Analysis
// ════════════════════════════════════════════════════════════════════

/// Fatigue state derived from yesterday-vs-today volume comparison.
enum FatigueState {
  /// Single series, steady volume.
  focused,

  /// Yesterday = high vol single series → today = low vol multi series.
  fragmented,

  /// Heavy yesterday, light today.
  lightFatigue,

  /// ≥ 30 chapters/day for 4+ consecutive days.
  burnout;

  String get displayLabel => switch (this) {
        FatigueState.focused => 'Focused',
        FatigueState.fragmented => 'Fragmented',
        FatigueState.lightFatigue => 'Light Fatigue',
        FatigueState.burnout => 'Burnout',
      };
}

/// Implicit mood derived from reading speed and time-of-day.
enum ImplicitMood {
  /// High speed + late night (21:00–02:00).
  fastBinge,

  /// Low speed + afternoon (12:00–17:00).
  calmReading,

  /// Default fallback.
  normalPace;

  String get displayLabel => switch (this) {
        ImplicitMood.fastBinge => 'Fast Binge',
        ImplicitMood.calmReading => 'Calm Reading',
        ImplicitMood.normalPace => 'Normal Pace',
      };
}

/// Composite user state consumed by the adaptive theme and insights feed.
class UserState {
  final FatigueState fatigue;
  final ImplicitMood mood;

  /// Efficiency score (0–100) from [ReadingDnaEngine].
  final double efficiencyScore;

  /// Human-readable dynamic label, e.g. "In the zone tonight".
  final String stateLabel;

  const UserState({
    required this.fatigue,
    required this.mood,
    required this.efficiencyScore,
    required this.stateLabel,
  });

  /// Whether the user is in a "hot" state (Efficiency > 80).
  bool get isHot => efficiencyScore > 80;

  /// Whether the user is in a "fatigued" state.
  bool get isFatigued =>
      fatigue == FatigueState.burnout ||
      fatigue == FatigueState.lightFatigue;

  static const empty = UserState(
    fatigue: FatigueState.focused,
    mood: ImplicitMood.normalPace,
    efficiencyScore: 0,
    stateLabel: 'No activity yet',
  );
}

// ════════════════════════════════════════════════════════════════════
// Unified V2 Snapshot
// ════════════════════════════════════════════════════════════════════

/// Top-level snapshot combining all Phase 14 analytics.
///
/// Consumed by the Insights UI, adaptive theme, and smart notifications.
class AnalyticsSnapshotV2 {
  final DnaProfile dna;
  final PredictiveSnapshot predictive;
  final UserState userState;

  /// Chapters per hour (0–23) for hourly distribution charts.
  final Map<int, int> hourlyDistribution;

  /// Chapters per weekday (1–7) for weekly pattern charts.
  final Map<int, int> weekdayDistribution;

  /// Chapters per day (normalized DateTime) for 30-day volume chart.
  final Map<DateTime, int> dailyTotals;

  /// Current consecutive reading streak in days.
  final int currentStreak;

  /// Longest streak ever achieved.
  final int longestStreak;

  const AnalyticsSnapshotV2({
    required this.dna,
    required this.predictive,
    required this.userState,
    required this.hourlyDistribution,
    required this.weekdayDistribution,
    required this.dailyTotals,
    required this.currentStreak,
    required this.longestStreak,
  });

  static final empty = AnalyticsSnapshotV2(
    dna: DnaProfile.empty,
    predictive: PredictiveSnapshot.empty,
    userState: UserState.empty,
    hourlyDistribution: const {},
    weekdayDistribution: const {},
    dailyTotals: const {},
    currentStreak: 0,
    longestStreak: 0,
  );
}
