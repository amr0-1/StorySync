import 'package:storysync/features/analytics/engine/analytics_models_v2.dart';

/// Pure computation engine for State & Mood Analysis.
///
/// Derives fatigue state and implicit mood from yesterday-vs-today
/// reading patterns and time-of-day activity.
///
/// All methods are stateless — safe for `compute()` / `Isolate.run()`.
class SessionAnalyzer {
  const SessionAnalyzer();

  /// Run the full session analysis pipeline.
  ///
  /// Returns a [UserState] with `efficiencyScore` set to 0 — the
  /// calling provider merges the actual score from [ReadingDnaEngine].
  UserState analyze(AggregatedLogsV2 agg) {
    final fatigue = _detectFatigue(agg);
    final mood = _detectMood(agg);
    final stateLabel = _buildStateLabel(fatigue, mood);

    return UserState(
      fatigue: fatigue,
      mood: mood,
      efficiencyScore: 0, // Merged by the provider with DNA score
      stateLabel: stateLabel,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Fatigue Detection
  // ════════════════════════════════════════════════════════════════

  /// Compare yesterday's reading pattern against today's to detect fatigue.
  ///
  /// Priority-ordered:
  /// 1. **Burnout** — ≥ 30 chapters/day for 4+ consecutive days.
  /// 2. **Fragmented** — Yesterday = high vol + single series,
  ///    today = low vol + multi series → "scattered reading".
  /// 3. **Light Fatigue** — Heavy yesterday (≥ 20 ch), light today (< 5 ch).
  /// 4. **Focused** — Default fallback.
  FatigueState _detectFatigue(AggregatedLogsV2 agg) {
    final now = _normalizeDate(DateTime.now());
    final yesterday = now.subtract(const Duration(days: 1));

    final todayLogs = agg.byDay[now] ?? [];
    final yesterdayLogs = agg.byDay[yesterday] ?? [];

    final todayVol = agg.dailyTotals[now] ?? 0;
    final yesterdayVol = agg.dailyTotals[yesterday] ?? 0;

    final todayTitles =
        todayLogs.map((l) => l.mangaDexId).toSet().length;
    final yesterdayTitles =
        yesterdayLogs.map((l) => l.mangaDexId).toSet().length;

    // ── Priority 1: Burnout ─────────────────────────────────
    // 4 consecutive days of ≥ 30 chapters each.
    int consecutiveHeavy = 0;
    for (int i = 0; i < 4; i++) {
      final date = now.subtract(Duration(days: i));
      final vol = agg.dailyTotals[date] ?? 0;
      if (vol >= 30) {
        consecutiveHeavy++;
      } else {
        break;
      }
    }
    if (consecutiveHeavy >= 4) return FatigueState.burnout;

    // ── Priority 2: Fragmented ──────────────────────────────
    // Yesterday = high vol + single series → today = low vol + multi series
    if (yesterdayVol >= 15 &&
        yesterdayTitles <= 1 &&
        todayVol < 5 &&
        todayTitles >= 2) {
      return FatigueState.fragmented;
    }

    // ── Priority 3: Light Fatigue ───────────────────────────
    // Heavy yesterday, light today
    if (yesterdayVol >= 20 && todayVol < 5) {
      return FatigueState.lightFatigue;
    }

    // ── Fallback ────────────────────────────────────────────
    return FatigueState.focused;
  }

  // ════════════════════════════════════════════════════════════════
  // Implicit Mood Detection
  // ════════════════════════════════════════════════════════════════

  /// Derive the implicit mood from today's reading speed and time-of-day.
  ///
  /// - **Fast Binge** — ≥ 10 chapters today + most recent read is late night.
  /// - **Calm Reading** — ≤ 5 chapters today + most recent read is afternoon.
  /// - **Normal Pace** — fallback.
  ImplicitMood _detectMood(AggregatedLogsV2 agg) {
    final now = _normalizeDate(DateTime.now());
    final todayVol = agg.dailyTotals[now] ?? 0;
    final todayLogs = agg.byDay[now] ?? [];

    if (todayLogs.isEmpty) return ImplicitMood.normalPace;

    // Find the hour of the most recent reading session today
    DateTime? latestTs;
    for (final log in todayLogs) {
      final ts = log.exactTimestamp;
      if (ts != null && (latestTs == null || ts.isAfter(latestTs))) {
        latestTs = ts;
      }
    }
    final latestHour = latestTs?.hour ?? 12;

    // Fast binge: high volume + late night (21:00–02:00)
    final isLateNight = latestHour >= 21 || latestHour <= 2;
    if (todayVol >= 10 && isLateNight) return ImplicitMood.fastBinge;

    // Calm reading: low volume + afternoon (12:00–17:00)
    final isAfternoon = latestHour >= 12 && latestHour <= 17;
    if (todayVol <= 5 && isAfternoon) return ImplicitMood.calmReading;

    return ImplicitMood.normalPace;
  }

  // ════════════════════════════════════════════════════════════════
  // State Label
  // ════════════════════════════════════════════════════════════════

  /// Build a human-readable dynamic state label.
  ///
  /// This label is appended to the DNA archetype in the UI:
  /// e.g., "Night Owl · ...but today was scattered"
  String _buildStateLabel(FatigueState fatigue, ImplicitMood mood) {
    return switch (fatigue) {
      FatigueState.burnout => 'Taking it too hard',
      FatigueState.fragmented => 'Today was scattered',
      FatigueState.lightFatigue => 'Winding down today',
      FatigueState.focused => switch (mood) {
          ImplicitMood.fastBinge => 'In the zone tonight',
          ImplicitMood.calmReading => 'Relaxed reading',
          ImplicitMood.normalPace => 'Steady pace',
        },
    };
  }

  // ════════════════════════════════════════════════════════════════
  // Helpers
  // ════════════════════════════════════════════════════════════════

  static DateTime _normalizeDate(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
