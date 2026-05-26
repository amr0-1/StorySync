import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/features/analytics/engine/analytics_models_v2.dart';
import 'package:storysync/features/analytics/engine/analytics_providers_v2.dart';

/// 30-day smoothed spline chart showing daily reading volume.
///
/// Design notes:
/// - Gold gradient fill matching VoidInkColors.goldSpark
/// - Touch/tooltips DISABLED to prevent swallowing vertical scroll events
/// - Subtle phase label (Growth / Stability / Decline) in the top-right
/// - Minimal axis decoration to preserve the Void Ink aesthetic
class VolumeChart extends ConsumerWidget {
  const VolumeChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(analyticsV2SnapshotProvider);

    return snapshot.when(
      data: (data) => _VolumeChartBody(data: data),
      loading: () => const _ChartSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _VolumeChartBody extends StatelessWidget {
  final AnalyticsSnapshotV2 data;
  const _VolumeChartBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    // Build 30 data points (one per day, oldest first)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final spots = <FlSpot>[];
    double maxY = 1;

    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final chapters = data.dailyTotals[date] ?? 0;
      spots.add(FlSpot((29 - i).toDouble(), chapters.toDouble()));
      maxY = max(maxY, chapters.toDouble());
    }

    // Add 20% headroom above the peak
    maxY = (maxY * 1.2).ceilToDouble();

    // Compute trend phase
    final phaseLabel = _computePhaseLabel(spots);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: colors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VOLUME · 30 DAYS',
                style: AppTextStyles.overline.copyWith(
                  color: colors.textHint,
                ),
              ),
              Text(
                phaseLabel,
                style: AppTextStyles.labelSmall.copyWith(
                  color: colors.goldDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),

          // ── Chart ──────────────────────────────────────────────
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: max(maxY / 4, 1),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colors.inkBorder.withValues(alpha: 0.3),
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 7,
                      getTitlesWidget: (value, meta) {
                        return _bottomTitle(value, today, colors);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                // CRITICAL: Disable all touch handling so the chart
                // does not consume vertical scroll events from the
                // parent ListView / CustomScrollView.
                lineTouchData: const LineTouchData(enabled: false),
                minX: 0,
                maxX: 29,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: colors.goldSpark,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.goldSpark.withValues(alpha: 0.15),
                          colors.goldSpark.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom axis labels — show abbreviated dates every 7 days.
  Widget _bottomTitle(double value, DateTime today, VoidInkColors colors) {
    final dayIndex = value.toInt();
    if (dayIndex % 7 != 0 && dayIndex != 29) {
      return const SizedBox.shrink();
    }

    final date = today.subtract(Duration(days: 29 - dayIndex));
    final label = '${date.day}/${date.month}';

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        label,
        style: AppTextStyles.monoSmall.copyWith(
          color: colors.textHint,
          fontSize: 9,
        ),
      ),
    );
  }

  /// Compute a simple trend label from the 30-day data.
  ///
  /// Splits into two 10-day halves and compares averages.
  String _computePhaseLabel(List<FlSpot> spots) {
    if (spots.length < 20) return '';

    double recentSum = 0;
    double previousSum = 0;

    // Recent 10 days (indices 20–29)
    for (int i = 20; i < 30; i++) {
      recentSum += spots[i].y;
    }
    // Previous 10 days (indices 10–19)
    for (int i = 10; i < 20; i++) {
      previousSum += spots[i].y;
    }

    if (previousSum == 0 && recentSum == 0) return '';
    if (previousSum == 0) return '📈 Growth';

    final ratio = recentSum / previousSum;
    if (ratio > 1.3) return '📈 Growth';
    if (ratio < 0.7) return '📉 Decline';
    return '→ Steady';
  }
}

/// Skeleton loading state matching the chart container dimensions.
class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: colors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation(colors.goldDim),
          ),
        ),
      ),
    );
  }
}
