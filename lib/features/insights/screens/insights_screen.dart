import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/shared/widgets/app_icon.dart';

final _insightsProvider = FutureProvider<_InsightsData>((ref) async {
  final isarService = ref.watch(isarServiceProvider);
  final allManga = await isarService.getAllManga();
  final allLogs = await isarService.getAllReadingLogs();

  final totalChapters = allLogs.fold<int>(
    0,
    (sum, log) => sum + log.chaptersRead,
  );

  final Map<DateTime, int> dailyChapters = {};
  for (final log in allLogs) {
    final normalizedDate = DateTime(
      log.date.year,
      log.date.month,
      log.date.day,
    );
    dailyChapters[normalizedDate] =
        (dailyChapters[normalizedDate] ?? 0) + log.chaptersRead;
  }

  return _InsightsData(
    librarySize: allManga.length,
    totalChaptersLogged: totalChapters,
    dailyChapters: dailyChapters,
  );
});

class _InsightsData {
  final int librarySize;
  final int totalChaptersLogged;
  final Map<DateTime, int> dailyChapters;

  _InsightsData({
    required this.librarySize,
    required this.totalChaptersLogged,
    required this.dailyChapters,
  });
}

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    final insightsAsync = ref.watch(_insightsProvider);

    return Scaffold(
      backgroundColor: colors.inkVoid,
      appBar: AppBar(
        backgroundColor: colors.inkVoid,
        surfaceTintColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon.small(),
            const SizedBox(width: AppDimensions.space8),
            Text(
              'Insights',
              style: AppTextStyles.headlineMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: insightsAsync.when(
        data: (data) => _buildContent(context, data, colors),
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colors.goldSpark),
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Text(
              'Failed to load insights',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    _InsightsData data,
    VoidInkColors colors,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.space16),
      children: [
        _buildStatCards(data, colors),
        const SizedBox(height: AppDimensions.space24),
        _buildHeatmapSection(context, data, colors),
      ],
    );
  }

  Widget _buildStatCards(_InsightsData data, VoidInkColors colors) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Titles in Library',
            value: data.librarySize.toString(),
            icon: Icons.collections_bookmark_rounded,
            colors: colors,
          ),
        ),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: _StatCard(
            label: 'Chapters Logged',
            value: data.totalChaptersLogged.toString(),
            icon: Icons.menu_book_rounded,
            colors: colors,
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmapSection(
    BuildContext context,
    _InsightsData data,
    VoidInkColors colors,
  ) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 150));

    Color getColor(int value) {
      if (value == 0) return colors.inkPanel;
      if (value <= 1) return colors.goldSpark.withValues(alpha: 0.2);
      if (value <= 3) return colors.goldSpark.withValues(alpha: 0.4);
      if (value <= 5) return colors.goldSpark.withValues(alpha: 0.6);
      if (value <= 10) return colors.goldSpark.withValues(alpha: 0.8);
      return colors.goldSpark;
    }

    final colorsets = <int, Color>{
      1: getColor(1),
      3: getColor(3),
      5: getColor(5),
      10: getColor(10),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTRIBUTION HEATMAP',
          style: AppTextStyles.overline.copyWith(color: colors.textHint),
        ),
        const SizedBox(height: AppDimensions.space12),
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HeatMap(
              startDate: startDate,
              endDate: endDate,
              datasets: data.dailyChapters,
              colorsets: colorsets,
              colorMode: ColorMode.opacity,
              textColor: colors.textSecondary,
              showColorTip: false,
              showText: false,
              scrollable: true,
              size: 14,
              borderRadius: 4,
              margin: const EdgeInsets.all(2),
              defaultColor: colors.inkPanel,
              onClick: (date) {
                final count = data.dailyChapters[date] ?? 0;
                final dateStr =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      count == 0
                          ? 'No chapters read on $dateStr'
                          : '$count chapter${count == 1 ? '' : 's'} read on $dateStr',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: colors.inkPanel,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSM,
                      ),
                      side: BorderSide(
                        color: colors.inkBorder,
                        width: AppDimensions.borderThin,
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.space8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Less',
              style: AppTextStyles.labelSmall.copyWith(color: colors.textHint),
            ),
            const SizedBox(width: AppDimensions.space4),
            ...[
              getColor(0),
              getColor(1),
              getColor(3),
              getColor(5),
              getColor(10),
            ].map(
              (colorValue) => Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: colorValue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space4),
            Text(
              'More',
              style: AppTextStyles.labelSmall.copyWith(color: colors.textHint),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidInkColors colors;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
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
          Icon(icon, size: 20, color: colors.goldSpark),
          const SizedBox(height: AppDimensions.space8),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.space2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
