import 'package:flutter/material.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';

/// Custom-built reading activity heatmap with threshold-based intensity,
/// tap interaction, and weekly summary bar chart.
class ReadingHeatmap extends StatelessWidget {
  final Map<DateTime, int> dailyTotals;
  final int daysToShow;
  final ValueChanged<DateTime>? onDayTapped;

  const ReadingHeatmap({
    super.key,
    required this.dailyTotals,
    this.daysToShow = 150,
    this.onDayTapped,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly summary bar
        _WeeklySummaryBar(dailyTotals: dailyTotals, colors: colors),
        const SizedBox(height: AppDimensions.space12),
        // Section label
        Text(
          'ACTIVITY',
          style: AppTextStyles.overline.copyWith(color: colors.textHint),
        ),
        const SizedBox(height: AppDimensions.space12),
        // Heatmap grid
        Container(
          padding: const EdgeInsets.all(AppDimensions.space12),
          decoration: BoxDecoration(
            color: colors.inkSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            border: Border.all(
              color: colors.inkBorder,
              width: AppDimensions.borderThin,
            ),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true, // Start from the right (today)
                child: _HeatmapGrid(
                  dailyTotals: dailyTotals,
                  daysToShow: daysToShow,
                  colors: colors,
                  onDayTapped: onDayTapped,
                ),
              ),
              const SizedBox(height: AppDimensions.space8),
              _buildLegend(colors),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(VoidInkColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Less',
          style: AppTextStyles.labelSmall.copyWith(color: colors.textHint),
        ),
        const SizedBox(width: AppDimensions.space4),
        ...[0, 3, 10, 35, 55].map(
          (value) => Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _getCellColor(value, colors),
              borderRadius: BorderRadius.circular(2),
              border: value > 50
                  ? Border.all(color: colors.goldSpark, width: 1)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.space4),
        Text(
          'More',
          style: AppTextStyles.labelSmall.copyWith(color: colors.textHint),
        ),
      ],
    );
  }

  static Color _getCellColor(int value, VoidInkColors colors) {
    if (value == 0) return colors.inkPanel;
    if (value <= 5) return colors.goldSpark.withValues(alpha: 0.25);
    if (value <= 20) return colors.goldSpark.withValues(alpha: 0.50);
    if (value <= 50) return colors.goldSpark.withValues(alpha: 0.80);
    return colors.goldSpark; // 50+ full intensity
  }
}

// ════════════════════════════════════════════════════════════════════
// Weekly Summary Bar
// ════════════════════════════════════════════════════════════════════

class _WeeklySummaryBar extends StatelessWidget {
  final Map<DateTime, int> dailyTotals;
  final VoidInkColors colors;

  const _WeeklySummaryBar({
    required this.dailyTotals,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate weekday offset (Monday = 1)
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    int weekTotal = 0;
    final List<int> dailyValues = [];

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final value = dailyTotals[date] ?? 0;
      weekTotal += value;
      dailyValues.add(value);
    }

    final maxValue = dailyValues.fold<int>(0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: colors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$weekTotal',
                style: AppTextStyles.monoLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'chapters this week',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          // Mini 7-day bar chart
          SizedBox(
            height: 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final normalizedHeight = maxValue > 0
                    ? (dailyValues[i] / maxValue).clamp(0.0, 1.0)
                    : 0.0;
                final isToday = i == today.weekday - 1;
                final isFuture =
                    startOfWeek.add(Duration(days: i)).isAfter(today);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: RepaintBoundary(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        height: isFuture
                            ? 2
                            : normalizedHeight > 0
                                ? (normalizedHeight * 28).clamp(4.0, 32.0)
                                : 2,
                        decoration: BoxDecoration(
                          color: isFuture
                              ? colors.inkPanel
                              : isToday
                                  ? colors.goldSpark
                                  : dailyValues[i] > 0
                                      ? colors.goldSpark.withValues(alpha: 0.5)
                                      : colors.inkMuted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppDimensions.space4),
          // Day labels
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: AppTextStyles.overline.copyWith(
                          color: colors.textHint,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Heatmap Grid
// ════════════════════════════════════════════════════════════════════

class _HeatmapGrid extends StatelessWidget {
  final Map<DateTime, int> dailyTotals;
  final int daysToShow;
  final VoidInkColors colors;
  final ValueChanged<DateTime>? onDayTapped;

  const _HeatmapGrid({
    required this.dailyTotals,
    required this.daysToShow,
    required this.colors,
    this.onDayTapped,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = today;
    final startDate = today.subtract(Duration(days: daysToShow));

    // Calculate total weeks
    final totalDays = endDate.difference(startDate).inDays + 1;
    final weeksCount = (totalDays / 7).ceil() + 1;

    // Build month labels
    final monthLabels = _buildMonthLabels(startDate, endDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels row
        Row(
          children: [
            const SizedBox(width: 20), // Space for day labels
            ...List.generate(weeksCount, (weekIdx) {
              final label = monthLabels[weekIdx];
              return SizedBox(
                width: 18,
                child: label != null
                    ? Text(
                        label,
                        style: AppTextStyles.overline.copyWith(
                          color: colors.textHint,
                          fontSize: 9,
                        ),
                      )
                    : null,
              );
            }),
          ],
        ),
        const SizedBox(height: AppDimensions.space4),
        // Grid with day labels
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels column
            Column(
              children: [
                _dayLabel('', colors), // Mon
                _dayLabel('M', colors),
                _dayLabel('', colors), // Wed
                _dayLabel('W', colors),
                _dayLabel('', colors), // Fri
                _dayLabel('F', colors),
                _dayLabel('', colors), // Sun
              ],
            ),
            // Cells grid
            ...List.generate(weeksCount, (weekIdx) {
              return Column(
                children: List.generate(7, (dayIdx) {
                  final date = _getDateForCell(
                      startDate, weekIdx, dayIdx);
                  if (date == null || date.isAfter(today)) {
                    return _emptyCell();
                  }
                  final value = dailyTotals[date] ?? 0;
                  return _HeatmapCell(
                    value: value,
                    date: date,
                    colors: colors,
                    onTap: value > 0 ? () => onDayTapped?.call(date) : null,
                  );
                }),
              );
            }),
          ],
        ),
      ],
    );
  }

  DateTime? _getDateForCell(DateTime startDate, int weekIdx, int dayIdx) {
    // Align to Monday
    final firstMonday =
        startDate.subtract(Duration(days: (startDate.weekday - 1) % 7));
    final date = firstMonday.add(Duration(days: weekIdx * 7 + dayIdx));
    if (date.isBefore(startDate)) return null;
    return DateTime(date.year, date.month, date.day);
  }

  Map<int, String> _buildMonthLabels(DateTime start, DateTime end) {
    final labels = <int, String>{};
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    int? lastMonth;
    final firstMonday =
        start.subtract(Duration(days: (start.weekday - 1) % 7));

    for (int week = 0; week <= (end.difference(start).inDays / 7).ceil() + 1; week++) {
      final weekStart = firstMonday.add(Duration(days: week * 7));
      if (weekStart.month != lastMonth) {
        labels[week] = months[weekStart.month - 1];
        lastMonth = weekStart.month;
      }
    }

    return labels;
  }

  Widget _dayLabel(String text, VoidInkColors colors) {
    return SizedBox(
      width: 16,
      height: 18,
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.overline.copyWith(
            color: colors.textHint,
            fontSize: 9,
          ),
        ),
      ),
    );
  }

  Widget _emptyCell() {
    return const SizedBox(width: 18, height: 18);
  }
}

// ════════════════════════════════════════════════════════════════════
// Individual Heatmap Cell
// ════════════════════════════════════════════════════════════════════

class _HeatmapCell extends StatelessWidget {
  final int value;
  final DateTime date;
  final VoidInkColors colors;
  final VoidCallback? onTap;

  const _HeatmapCell({
    required this.value,
    required this.date,
    required this.colors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cellColor = ReadingHeatmap._getCellColor(value, colors);
    final isExtreme = value > 50;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: cellColor,
            borderRadius: BorderRadius.circular(3),
            border: isExtreme
                ? Border.all(
                    color: colors.goldLight.withValues(alpha: 0.6),
                    width: 1,
                  )
                : null,
            boxShadow: isExtreme
                ? [
                    BoxShadow(
                      color: colors.goldSpark.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
