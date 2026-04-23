import 'package:flutter/material.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';

/// Displays the reading personality title with gradient text effect
/// and current streak counter with fire icon.
class PersonalityHeader extends StatefulWidget {
  final String personalityTitle;
  final String personalitySubtitle;
  final int currentStreak;

  const PersonalityHeader({
    super.key,
    required this.personalityTitle,
    required this.personalitySubtitle,
    required this.currentStreak,
  });

  @override
  State<PersonalityHeader> createState() => _PersonalityHeaderState();
}

class _PersonalityHeaderState extends State<PersonalityHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space24),
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
          // Personality title with shimmer gradient
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, _) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  final offset = _shimmerController.value * 2 - 0.5;
                  return LinearGradient(
                    begin: Alignment(offset - 0.5, 0),
                    end: Alignment(offset + 0.5, 0),
                    colors: [
                      colors.goldDim,
                      colors.goldSpark,
                      colors.goldLight,
                      colors.goldSpark,
                      colors.goldDim,
                    ],
                    stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                  ).createShader(bounds);
                },
                child: Text(
                  widget.personalityTitle,
                  style: AppTextStyles.displayLarge.copyWith(
                    color: Colors.white, // Shader mask needs white base
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.space4),
          Text(
            widget.personalitySubtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          // Streak counter
          Row(
            children: [
              _StreakBadge(
                streak: widget.currentStreak,
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  final VoidInkColors colors;

  const _StreakBadge({
    required this.streak,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final hasStreak = streak > 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space8,
      ),
      decoration: BoxDecoration(
        color: hasStreak
            ? colors.goldSpark.withValues(alpha: 0.12)
            : colors.inkPanel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: hasStreak
              ? colors.goldSpark.withValues(alpha: 0.3)
              : colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 16,
            color: hasStreak ? colors.goldSpark : colors.textHint,
          ),
          const SizedBox(width: AppDimensions.space4),
          Text(
            hasStreak ? '$streak-day streak' : 'No active streak',
            style: AppTextStyles.labelMedium.copyWith(
              color: hasStreak ? colors.goldSpark : colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// AnimatedBuilder wrapper for shimmer effect.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
