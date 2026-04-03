import 'package:flutter/material.dart';
import 'package:mtrack/core/theme/app_colors.dart';
import 'package:mtrack/core/theme/app_dimensions.dart';
import 'package:mtrack/core/theme/app_text_styles.dart';

/// A stepper widget for incrementing/decrementing chapter progress
class ChapterStepper extends StatelessWidget {
  /// The current chapter number
  final int currentChapter;

  /// The total number of chapters (optional)
  final int? totalChapters;

  /// Callback when the chapter value changes
  final ValueChanged<int> onChanged;

  const ChapterStepper({
    super.key,
    required this.currentChapter,
    required this.totalChapters,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalChapters != null
        ? (totalChapters! - currentChapter).clamp(0, totalChapters!)
        : null;
    final progress = totalChapters != null && totalChapters! > 0
        ? (currentChapter / totalChapters!).clamp(0.0, 1.0)
        : 0.0;
    final progressPercent = (progress * 100).round();

    return Column(
      children: [
        // Label
        Text('CURRENT CHAPTER', style: AppTextStyles.overline),
        const SizedBox(height: AppDimensions.space12),

        // Stepper controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minus button
            _StepperButton(
              icon: Icons.remove_rounded,
              onTap: currentChapter > 0
                  ? () => onChanged(currentChapter - 1)
                  : null,
            ),
            const SizedBox(width: 20),

            // Chapter display
            Column(
              children: [
                Text('$currentChapter', style: AppTextStyles.monoLarge),
                if (totalChapters != null)
                  Text('/  $totalChapters', style: AppTextStyles.overline),
              ],
            ),
            const SizedBox(width: 20),

            // Plus button
            _StepperButton(
              icon: Icons.add_rounded,
              onTap: () => onChanged(currentChapter + 1),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space16),

        // Stats row
        Row(
          children: [
            // Remaining stat
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.inkPanel,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('REMAINING', style: AppTextStyles.overline),
                    const SizedBox(height: 4),
                    Text(
                      remaining != null ? '$remaining' : '—',
                      style: AppTextStyles.monoMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space12),

            // Progress stat
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.inkPanel,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROGRESS', style: AppTextStyles.overline),
                    const SizedBox(height: 4),
                    Text(
                      totalChapters != null ? '$progressPercent%' : '—',
                      style: AppTextStyles.monoMedium.copyWith(
                        color: AppColors.goldSpark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space12),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.inkBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.goldSpark,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

/// Individual stepper button
class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.inkPanel,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          border: Border.all(
            color: AppColors.inkBorder,
            width: AppDimensions.borderThin,
          ),
        ),
        child: Icon(
          icon,
          color: isEnabled ? AppColors.textPrimary : AppColors.textHint,
          size: 20,
        ),
      ),
    );
  }
}
