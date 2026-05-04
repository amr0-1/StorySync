import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/features/insights/data/analytics_models.dart';
import 'package:storysync/features/insights/data/analytics_providers.dart';
import 'package:storysync/features/insights/widgets/insight_cards.dart';
import 'package:storysync/features/insights/widgets/personality_header.dart';
import 'package:storysync/features/insights/widgets/reading_heatmap.dart';
import 'package:storysync/shared/widgets/app_icon.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const InsightsScreen({super.key, this.initialDate});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only trigger if we have colors available
        final colors = Theme.of(context).extension<VoidInkColors>();
        if (colors != null) {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (sheetContext) {
              return _DayDetailBottomSheet(
                date: widget.initialDate!,
                colors: colors,
              );
            },
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    final snapshotAsync = ref.watch(analyticsSnapshotProvider);

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
      body: snapshotAsync.when(
        data: (snapshot) => _InsightsBody(snapshot: snapshot),
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colors.goldSpark),
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: colors.statusDropped,
                  size: 32,
                ),
                const SizedBox(height: AppDimensions.space12),
                Text(
                  'Failed to load insights',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Insights Body
// ════════════════════════════════════════════════════════════════════

class _InsightsBody extends ConsumerWidget {
  final AnalyticsSnapshot snapshot;

  const _InsightsBody({required this.snapshot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.space16),
      children: [
        // ── Personality Header ─────────────────────────────────
        PersonalityHeader(
          personalityTitle: snapshot.personalityTitle,
          personalitySubtitle: snapshot.personalitySubtitle,
          currentStreak: snapshot.streaks.current,
        ),
        const SizedBox(height: AppDimensions.space24),

        // ── Interactive Heatmap & Weekly Summary ───────────────
        ReadingHeatmap(
          dailyTotals: snapshot.dailyTotals,
          daysToShow: 150,
          onDayTapped: (date) {
            _showDayDetailSheet(context, ref, date, colors);
          },
        ),
        const SizedBox(height: AppDimensions.space24),

        // ── Dynamic Insight Cards ──────────────────────────────
        InsightCards(insights: snapshot.insights),
        const SizedBox(height: AppDimensions.space24),

        // ── Stats Row ──────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Titles in Library',
                value: snapshot.librarySize.toString(),
                icon: Icons.collections_bookmark_rounded,
                colors: colors,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: _StatCard(
                label: 'Chapters Logged',
                value: snapshot.totalChaptersLogged.toString(),
                icon: Icons.menu_book_rounded,
                colors: colors,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space16),

        // ── Velocity Trend Card ────────────────────────────────
        _VelocityCard(velocity: snapshot.velocity, colors: colors),
        const SizedBox(height: AppDimensions.space16),

        // ── Title Analytics ────────────────────────────────────
        if (snapshot.titleAnalytics.topSeries.isNotEmpty) ...[
          _TitleAnalyticsSection(
            titleAnalytics: snapshot.titleAnalytics,
            colors: colors,
          ),
          const SizedBox(height: AppDimensions.space16),
        ],

        // ── Streak Stats ───────────────────────────────────────
        if (snapshot.streaks.longest > 0)
          _StreakCard(streaks: snapshot.streaks, colors: colors),

        const SizedBox(height: AppDimensions.space48),
      ],
    );
  }

  void _showDayDetailSheet(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    VoidInkColors colors,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _DayDetailBottomSheet(date: date, colors: colors);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Stat Card
// ════════════════════════════════════════════════════════════════════

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

// ════════════════════════════════════════════════════════════════════
// Velocity Trend Card
// ════════════════════════════════════════════════════════════════════

class _VelocityCard extends StatelessWidget {
  final VelocityTrend velocity;
  final VoidInkColors colors;

  const _VelocityCard({required this.velocity, required this.colors});

  @override
  Widget build(BuildContext context) {
    final icon = switch (velocity.direction) {
      TrendDirection.up => Icons.trending_up_rounded,
      TrendDirection.stable => Icons.trending_flat_rounded,
      TrendDirection.down => Icons.trending_down_rounded,
    };

    final iconColor = switch (velocity.direction) {
      TrendDirection.up => colors.statusReading,
      TrendDirection.stable => colors.goldSpark,
      TrendDirection.down => colors.statusDropped,
    };

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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'READING VELOCITY',
                  style: AppTextStyles.overline.copyWith(
                    color: colors.textHint,
                  ),
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  velocity.displayText,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.space2),
                Text(
                  '${velocity.last7} ch (last 7d) vs ${velocity.prev7} ch (prev 7d)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Title Analytics Section
// ════════════════════════════════════════════════════════════════════

class _TitleAnalyticsSection extends StatelessWidget {
  final TitleAnalytics titleAnalytics;
  final VoidInkColors colors;

  const _TitleAnalyticsSection({
    required this.titleAnalytics,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top series
        if (titleAnalytics.topSeries.isNotEmpty) ...[
          Text(
            'TOP SERIES',
            style: AppTextStyles.overline.copyWith(color: colors.textHint),
          ),
          const SizedBox(height: AppDimensions.space8),
          ...titleAnalytics.topSeries.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final stat = entry.value;
            return _TitleStatTile(rank: rank, stat: stat, colors: colors);
          }),
        ],
        // Cold series
        if (titleAnalytics.coldSeries.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space16),
          Text(
            'WAITING FOR YOU',
            style: AppTextStyles.overline.copyWith(color: colors.textHint),
          ),
          const SizedBox(height: AppDimensions.space8),
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
            child: Row(
              children: [
                Icon(
                  Icons.ac_unit_rounded,
                  size: 18,
                  color: colors.statusPlanToRead,
                ),
                const SizedBox(width: AppDimensions.space8),
                Expanded(
                  child: Text(
                    '${titleAnalytics.coldSeries.length} series with no activity for 14+ days',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        // Hot/Binge series
        if (titleAnalytics.hotSeries.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space16),
          Text(
            'BINGE READS',
            style: AppTextStyles.overline.copyWith(color: colors.textHint),
          ),
          const SizedBox(height: AppDimensions.space8),
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: colors.inkSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              border: Border.all(
                color: colors.goldSpark.withValues(alpha: 0.25),
                width: AppDimensions.borderThin,
              ),
            ),
            child: Column(
              children: titleAnalytics.hotSeries.take(3).map((stat) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 18,
                        color: colors.goldSpark,
                      ),
                      const SizedBox(width: AppDimensions.space8),
                      Expanded(
                        child: Text(
                          stat.title,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${stat.totalChapters} ch.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _TitleStatTile extends StatelessWidget {
  final int rank;
  final TitleStat stat;
  final VoidInkColors colors;

  const _TitleStatTile({
    required this.rank,
    required this.stat,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space8),
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: colors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank == 1
                  ? colors.goldSpark.withValues(alpha: 0.15)
                  : colors.inkPanel,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: AppTextStyles.monoSmall.copyWith(
                  color: rank == 1 ? colors.goldSpark : colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${stat.totalChapters} chapters logged',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Streak Card
// ════════════════════════════════════════════════════════════════════

class _StreakCard extends StatelessWidget {
  final StreakData streaks;
  final VoidInkColors colors;

  const _StreakCard({required this.streaks, required this.colors});

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 24,
                  color: streaks.current > 0
                      ? colors.goldSpark
                      : colors.textHint,
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  '${streaks.current}',
                  style: AppTextStyles.monoLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  'Current',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: AppDimensions.borderThin,
            height: 48,
            color: colors.inkBorder,
          ),
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  size: 24,
                  color: colors.goldLight,
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  '${streaks.longest}',
                  style: AppTextStyles.monoLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  'Longest',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Day Detail Bottom Sheet
// ════════════════════════════════════════════════════════════════════

class _DayDetailBottomSheet extends ConsumerWidget {
  final DateTime date;
  final VoidInkColors colors;

  const _DayDetailBottomSheet({required this.date, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayDetailAsync = ref.watch(dayDetailProvider(date));

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr = '${months[date.month - 1]} ${date.day}, ${date.year}';
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = weekdays[date.weekday - 1];

    return Container(
      decoration: BoxDecoration(
        color: colors.inkSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLG),
        ),
        border: Border(
          top: BorderSide(
            color: colors.inkBorder,
            width: AppDimensions.borderThin,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: AppDimensions.space12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.inkMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space24,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: colors.goldSpark,
                ),
                const SizedBox(width: AppDimensions.space8),
                Text(
                  '$dayName, $dateStr',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          // Content
          dayDetailAsync.when(
            data: (detail) => _buildDetailContent(detail),
            loading: () => Padding(
              padding: const EdgeInsets.all(AppDimensions.space24),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colors.goldSpark),
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (e, st) => Padding(
              padding: const EdgeInsets.all(AppDimensions.space24),
              child: Text(
                'Failed to load details',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildDetailContent(DayDetail detail) {
    if (detail.totalChapters == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space24,
          vertical: AppDimensions.space12,
        ),
        child: Row(
          children: [
            Icon(Icons.circle_outlined, size: 16, color: colors.textHint),
            const SizedBox(width: AppDimensions.space8),
            Text(
              'No chapters read on this day',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total summary
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: colors.goldSpark.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 20,
                  color: colors.goldSpark,
                ),
                const SizedBox(width: AppDimensions.space8),
                Text(
                  '${detail.totalChapters} chapter${detail.totalChapters == 1 ? '' : 's'} total',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '~${(detail.titles.length)} session${detail.titles.length == 1 ? '' : 's'}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
          // Title breakdown
          ...detail.titles.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.goldSpark.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${entry.chaptersRead} ch.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
