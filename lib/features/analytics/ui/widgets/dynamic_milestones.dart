import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/features/analytics/engine/analytics_models_v2.dart';
import 'package:storysync/features/analytics/engine/analytics_providers_v2.dart';

/// Dynamic milestones widget that replaces static goals with real
/// achievements derived from the user's actual reading history.
///
/// Displays a horizontally scrollable row of achievement cards:
/// - 🔥 Longest Streak (days)
/// - ⚡ Max Chapters in a Single Day
/// - 📚 Total Chapters Logged (all-time)
/// - 🏆 Most-Read Series (by chapter count)
class DynamicMilestones extends ConsumerWidget {
  const DynamicMilestones({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(analyticsV2SnapshotProvider);

    return snapshot.when(
      data: (data) => _MilestonesBody(data: data),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _MilestonesBody extends StatelessWidget {
  final AnalyticsSnapshotV2 data;
  const _MilestonesBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    final milestones = _buildMilestones(data);

    if (milestones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACHIEVEMENTS',
          style: AppTextStyles.overline.copyWith(color: colors.textHint),
        ),
        const SizedBox(height: AppDimensions.space12),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: milestones.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppDimensions.space8),
            itemBuilder: (context, index) {
              return _MilestoneCard(
                milestone: milestones[index],
                colors: colors,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }

  List<_MilestoneData> _buildMilestones(AnalyticsSnapshotV2 snapshot) {
    final milestones = <_MilestoneData>[];

    // ── Longest Streak ────────────────────────────────────────
    if (snapshot.longestStreak > 0) {
      milestones.add(_MilestoneData(
        icon: '🔥',
        value: '${snapshot.longestStreak}',
        label: 'Longest Streak',
        suffix: snapshot.longestStreak == 1 ? 'day' : 'days',
      ));
    }

    // ── Max Chapters in a Single Day ──────────────────────────
    if (snapshot.dailyTotals.isNotEmpty) {
      final maxInDay =
          snapshot.dailyTotals.values.fold<int>(0, (a, b) => max(a, b));
      if (maxInDay > 0) {
        milestones.add(_MilestoneData(
          icon: '⚡',
          value: '$maxInDay',
          label: 'Best Day',
          suffix: maxInDay == 1 ? 'chapter' : 'chapters',
        ));
      }
    }

    // ── Total Chapters (all-time) ─────────────────────────────
    if (snapshot.dailyTotals.isNotEmpty) {
      final total =
          snapshot.dailyTotals.values.fold<int>(0, (a, b) => a + b);
      if (total > 0) {
        milestones.add(_MilestoneData(
          icon: '📚',
          value: _formatLargeNumber(total),
          label: 'Total Read',
          suffix: 'chapters',
        ));
      }
    }

    // ── Most-Read Series ──────────────────────────────────────
    if (snapshot.predictive.seriesLifecycles.isNotEmpty) {
      // Find the series with the highest peak daily volume as a proxy
      // for engagement intensity
      final sorted = snapshot.predictive.seriesLifecycles.toList()
        ..sort((a, b) => b.peakDailyVolume.compareTo(a.peakDailyVolume));
      final top = sorted.first;
      milestones.add(_MilestoneData(
        icon: '🏆',
        value: _truncateTitle(top.title),
        label: 'Most Engaged',
        suffix: '${top.peakDailyVolume} ch/day peak',
      ));
    }

    // ── Current Streak (if active) ────────────────────────────
    if (snapshot.currentStreak >= 3) {
      milestones.add(_MilestoneData(
        icon: '📅',
        value: '${snapshot.currentStreak}',
        label: 'Active Streak',
        suffix: 'days running',
      ));
    }

    return milestones;
  }

  static String _formatLargeNumber(int n) {
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(1)}K';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  static String _truncateTitle(String title) {
    if (title.length <= 14) return title;
    return '${title.substring(0, 12)}…';
  }
}

// ════════════════════════════════════════════════════════════════════
// Milestone Card
// ════════════════════════════════════════════════════════════════════

class _MilestoneCard extends StatefulWidget {
  final _MilestoneData milestone;
  final VoidInkColors colors;
  final int index;

  const _MilestoneCard({
    required this.milestone,
    required this.colors,
    required this.index,
  });

  @override
  State<_MilestoneCard> createState() => _MilestoneCardState();
}

class _MilestoneCardState extends State<_MilestoneCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleIn;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleIn = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // Staggered entry: each card delays slightly based on index
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
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
      child: ScaleTransition(
        scale: _scaleIn,
        child: Container(
          width: 140,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space12,
            vertical: AppDimensions.space12,
          ),
          decoration: BoxDecoration(
            color: widget.colors.inkSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            border: Border.all(
              color: widget.colors.inkBorder,
              width: AppDimensions.borderThin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon
              Text(
                widget.milestone.icon,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: AppDimensions.space4),
              // Value (prominent)
              Text(
                widget.milestone.value,
                style: AppTextStyles.titleMedium.copyWith(
                  color: widget.colors.goldSpark,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Label
              Text(
                widget.milestone.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: widget.colors.textSecondary,
                ),
              ),
              // Suffix
              Text(
                widget.milestone.suffix,
                style: AppTextStyles.monoSmall.copyWith(
                  color: widget.colors.textHint,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Data Model
// ════════════════════════════════════════════════════════════════════

class _MilestoneData {
  final String icon;
  final String value;
  final String label;
  final String suffix;

  const _MilestoneData({
    required this.icon,
    required this.value,
    required this.label,
    required this.suffix,
  });
}
