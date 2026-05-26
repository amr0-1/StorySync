import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:storysync/features/analytics/engine/analytics_models_v2.dart';

/// Lightweight analytics cache for the background worker.
///
/// The `workmanager` background task runs in a separate isolate and
/// CANNOT access Riverpod providers or the full Isar analytics engine.
/// This service bridges that gap by serializing key analytics results
/// into a small JSON blob in [SharedPreferences], which the worker
/// reads to generate context-aware notification payloads.
///
/// **Write path:** Main app → [analyticsV2SnapshotProvider] updates
///   → [saveSnapshot] writes to SharedPreferences.
///
/// **Read path:** Background worker → [loadCachedAnalytics] reads
///   from SharedPreferences → generates notification text.
class AnalyticsCacheService {
  AnalyticsCacheService._();
  static final instance = AnalyticsCacheService._();

  /// SharedPreferences key for the cached analytics JSON.
  static const String _cacheKey = 'storysync_analytics_cache';

  /// Serialize the essential analytics fields to SharedPreferences.
  ///
  /// Called whenever the V2 analytics snapshot updates. Only stores
  /// fields needed by the background worker — no large collections.
  Future<void> saveSnapshot(AnalyticsSnapshotV2 snapshot) async {
    final prefs = await SharedPreferences.getInstance();

    final cache = {
      'currentStreak': snapshot.currentStreak,
      'longestStreak': snapshot.longestStreak,
      'peakHour': snapshot.dna.habitLoop.peakHourOfDay,
      'peakDay': snapshot.dna.habitLoop.peakDayOfWeek,
      'peakHourLabel': snapshot.dna.habitLoop.peakHourLabel,
      'fatigueState': snapshot.userState.fatigue.name,
      'efficiencyScore': snapshot.userState.efficiencyScore,
      'archetypeTitle': snapshot.dna.archetypeTitle,
      'stateLabel': snapshot.userState.stateLabel,
      'dropOffRiskTitles': snapshot.predictive.dropOffRisks
          .take(3) // Limit to top 3 to keep the blob small
          .map((e) => e.title)
          .toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_cacheKey, jsonEncode(cache));
  }

  /// Read the cached analytics from SharedPreferences.
  ///
  /// Returns null if no cache exists (e.g., first launch before
  /// the analytics engine has run). The background worker must
  /// handle this gracefully by falling back to basic behavior.
  static Future<CachedAnalytics?> loadCachedAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_cacheKey);

    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return CachedAnalytics.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}

/// Minimal data class representing the cached analytics blob.
///
/// Designed for consumption by the background worker — contains
/// only the fields needed for notification scheduling and payloads.
class CachedAnalytics {
  final int currentStreak;
  final int longestStreak;
  final int peakHour;
  final int peakDay;
  final String peakHourLabel;
  final String fatigueState;
  final double efficiencyScore;
  final String archetypeTitle;
  final String stateLabel;
  final List<String> dropOffRiskTitles;
  final DateTime updatedAt;

  const CachedAnalytics({
    required this.currentStreak,
    required this.longestStreak,
    required this.peakHour,
    required this.peakDay,
    required this.peakHourLabel,
    required this.fatigueState,
    required this.efficiencyScore,
    required this.archetypeTitle,
    required this.stateLabel,
    required this.dropOffRiskTitles,
    required this.updatedAt,
  });

  factory CachedAnalytics.fromJson(Map<String, dynamic> json) {
    return CachedAnalytics(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      peakHour: json['peakHour'] as int? ?? 20,
      peakDay: json['peakDay'] as int? ?? 1,
      peakHourLabel: json['peakHourLabel'] as String? ?? '8 PM',
      fatigueState: json['fatigueState'] as String? ?? 'focused',
      efficiencyScore: (json['efficiencyScore'] as num?)?.toDouble() ?? 0.0,
      archetypeTitle: json['archetypeTitle'] as String? ?? 'Reader',
      stateLabel: json['stateLabel'] as String? ?? 'Steady pace',
      dropOffRiskTitles: (json['dropOffRiskTitles'] as List<dynamic>?)
              ?.cast<String>() ??
          const [],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Whether the user is in a fatigued state (burnout or lightFatigue).
  bool get isFatigued =>
      fatigueState == 'burnout' || fatigueState == 'lightFatigue';
}
