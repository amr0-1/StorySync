import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/features/analytics/engine/analytics_models_v2.dart';
import 'package:storysync/features/analytics/engine/analytics_providers_v2.dart';

/// Context-aware insights feed with ephemeral logic gates.
///
/// Cards appear / disappear with fluid transitions based on real-time
/// analytics state. Only shows cards when their trigger conditions are
/// met — no empty states, no placeholder filler.
///
/// Features:
/// - **Layered Title:** DNA archetype + dynamic state suffix
/// - **Burnout Alert:** > 50 chapters in 24h
/// - **Comeback Power:** returning after a 5+ day break
/// - **Drop-off Risk:** series flagged by the predictive engine
/// - **Streak Momentum:** consistency in top tier
class SmartInsightsFeed extends ConsumerWidget {
  const SmartInsightsFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(analyticsV2SnapshotProvider);

    return snapshot.when(
      data: (data) => _InsightsFeedBody(data: data),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _InsightsFeedBody extends StatelessWidget {
  final AnalyticsSnapshotV2 data;
  const _InsightsFeedBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    final insights = _buildActiveInsights(data, colors);

    // Don't render the entire widget if there's nothing to show
    if (insights.isEmpty && data.dna.archetype == DnaArchetype.balancedReader) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Layered Title ──────────────────────────────────────
        _LayeredTitle(data: data, colors: colors),
        if (insights.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space12),

          // ── Insight Cards with animated transitions ───────────
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Column(
              children: insights.map((insight) {
                return _AnimatedInsightCard(
                  key: ValueKey(insight.id),
                  insight: insight,
                  colors: colors,
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  /// Build the list of currently active insight cards.
  ///
  /// Each insight has a trigger condition (the "ephemeral logic gate").
  /// Only insights whose conditions are met appear in the feed.
  List<_InsightData> _buildActiveInsights(
    AnalyticsSnapshotV2 snapshot,
    VoidInkColors colors,
  ) {
    final insights = <_InsightData>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // ── Burnout Alert ─────────────────────────────────────────
    final todayChapters = snapshot.dailyTotals[today] ?? 0;
    if (todayChapters > 50) {
      insights.add(_InsightData(
        id: 'burnout',
        icon: '🔥',
        title: 'Burnout Alert',
        subtitle:
            'You\'ve read $todayChapters chapters today. Consider a breather.',
        accentColor: colors.statusDropped,
      ));
    }

    // ── Comeback Power ────────────────────────────────────────
    // Show if reading today after a 5+ day gap
    if (todayChapters > 0) {
      final sortedDates = snapshot.dailyTotals.keys
          .where((d) => d.isBefore(today))
          .toList()
        ..sort();
      if (sortedDates.isNotEmpty) {
        final lastBefore = sortedDates.last;
        final gap = today.difference(lastBefore).inDays;
        if (gap >= 5) {
          final avgGap = snapshot.predictive.comebackPower.averageGapDays;
          insights.add(_InsightData(
            id: 'comeback',
            icon: '💪',
            title: 'Welcome Back!',
            subtitle:
                'Returned after $gap days. Your average comeback: '
                '${avgGap.toStringAsFixed(1)} days.',
            accentColor: colors.statusReading,
          ));
        }
      }
    }

    // ── Drop-off Risk ─────────────────────────────────────────
    if (snapshot.predictive.dropOffRisks.isNotEmpty) {
      final risk = snapshot.predictive.dropOffRisks.first;
      insights.add(_InsightData(
        id: 'dropoff_${risk.mangaDexId}',
        icon: '⚠️',
        title: 'At Risk: ${risk.title}',
        subtitle:
            'No activity for ${risk.daysSinceLastRead} days. '
            'You usually return after '
            '${snapshot.predictive.comebackPower.averageGapDays.toStringAsFixed(0)} days.',
        accentColor: colors.statusOnHold,
      ));
    }

    // ── Streak Momentum ───────────────────────────────────────
    if (snapshot.currentStreak >= 7) {
      insights.add(_InsightData(
        id: 'streak_momentum',
        icon: '🔥',
        title: '${snapshot.currentStreak}-Day Streak',
        subtitle:
            'Your consistency is paying off. '
            'Personal best: ${snapshot.longestStreak} days.',
        accentColor: colors.goldSpark,
      ));
    }

    return insights;
  }
}

// ════════════════════════════════════════════════════════════════════
// Layered Title
// ════════════════════════════════════════════════════════════════════

/// DNA archetype title + dynamic state suffix.
///
/// Example: "🦉 Night Owl" / "...but today was scattered"
class _LayeredTitle extends StatelessWidget {
  final AnalyticsSnapshotV2 data;
  final VoidInkColors colors;

  const _LayeredTitle({required this.data, required this.colors});

  @override
  Widget build(BuildContext context) {
    final archetype = data.dna.archetype;
    final stateLabel = data.userState.stateLabel;
    final isDefaultState = stateLabel == 'Steady pace';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: Column(
        key: ValueKey('${archetype.name}_$stateLabel'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary: Archetype identity
          Row(
            children: [
              Text(
                archetype.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: AppDimensions.space8),
              Text(
                archetype.displayTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: colors.goldSpark,
                ),
              ),
            ],
          ),
          // Secondary: Dynamic state (only shown when non-default)
          if (!isDefaultState) ...[
            const SizedBox(height: AppDimensions.space4),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                '...$stateLabel',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Animated Insight Card
// ════════════════════════════════════════════════════════════════════

/// Single insight card with fade + slide-in animation on mount.
class _AnimatedInsightCard extends StatefulWidget {
  final _InsightData insight;
  final VoidInkColors colors;

  const _AnimatedInsightCard({
    super.key,
    required this.insight,
    required this.colors,
  });

  @override
  State<_AnimatedInsightCard> createState() => _AnimatedInsightCardState();
}

class _AnimatedInsightCardState extends State<_AnimatedInsightCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideIn,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.space8),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.space16),
            decoration: BoxDecoration(
              color: widget.colors.inkSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              border: Border.all(
                color: widget.colors.inkBorder,
                width: AppDimensions.borderThin,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Accent bar
                Container(
                  width: 3,
                  height: 36,
                  margin: const EdgeInsets.only(right: AppDimensions.space12),
                  decoration: BoxDecoration(
                    color: widget.insight.accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Icon
                Text(
                  widget.insight.icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: AppDimensions.space12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.insight.title,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: widget.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        widget.insight.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: widget.colors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
// Data Model
// ════════════════════════════════════════════════════════════════════

class _InsightData {
  final String id;
  final String icon;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _InsightData({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}
