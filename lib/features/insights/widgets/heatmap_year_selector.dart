import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/core/utils/haptic_util.dart';
import 'package:storysync/features/insights/providers/heatmap_provider.dart';

/// Sleek horizontal year selector for the Insights Hub heatmap.
///
/// Renders `< YYYY >` with animated transitions when the user navigates
/// between years. Right arrow is disabled at the current year.
class HeatmapYearSelector extends ConsumerWidget {
  const HeatmapYearSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    final selectedYear = ref.watch(heatmapYearProvider);
    final currentYear = DateTime.now().year;
    final isAtCurrentYear = selectedYear >= currentYear;

    // Don't allow going earlier than 2020 (sensible lower bound).
    final isAtMinYear = selectedYear <= 2020;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.space8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left arrow
          _YearArrowButton(
            icon: Icons.chevron_left_rounded,
            colors: colors,
            enabled: !isAtMinYear,
            onPressed: () {
              StorySyncHaptics.lightTap();
              ref.read(heatmapYearProvider.notifier).state =
                  selectedYear - 1;
            },
          ),
          const SizedBox(width: AppDimensions.space16),

          // Year label with animated transition
          SizedBox(
            width: 72,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                '$selectedYear',
                key: ValueKey(selectedYear),
                textAlign: TextAlign.center,
                style: AppTextStyles.monoMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.space16),

          // Right arrow
          _YearArrowButton(
            icon: Icons.chevron_right_rounded,
            colors: colors,
            enabled: !isAtCurrentYear,
            onPressed: () {
              StorySyncHaptics.lightTap();
              ref.read(heatmapYearProvider.notifier).state =
                  selectedYear + 1;
            },
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Arrow Button
// ════════════════════════════════════════════════════════════════════

class _YearArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidInkColors colors;
  final bool enabled;
  final VoidCallback onPressed;

  const _YearArrowButton({
    required this.icon,
    required this.colors,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? colors.inkPanel
              : colors.inkPanel.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          border: Border.all(
            color: enabled ? colors.inkBorder : Colors.transparent,
            width: AppDimensions.borderThin,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? colors.textSecondary : colors.textHint,
        ),
      ),
    );
  }
}
