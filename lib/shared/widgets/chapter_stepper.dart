import 'package:flutter/material.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/utils/haptic_util.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';

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
    final colors = Theme.of(context).extension<VoidInkColors>()!;
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
        Text('CURRENT CHAPTER', style: AppTextStyles.overline.copyWith(color: colors.textHint)),
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

            // Chapter display with animated switcher
            Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Text(
                    '$currentChapter',
                    key: ValueKey<int>(currentChapter),
                    style: AppTextStyles.monoLarge.copyWith(color: colors.textPrimary),
                  ),
                ),
                if (totalChapters != null)
                  Text('/  $totalChapters', style: AppTextStyles.overline.copyWith(color: colors.textHint)),
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
                  color: colors.inkPanel,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('REMAINING', style: AppTextStyles.overline.copyWith(color: colors.textHint)),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      remaining != null ? '$remaining' : '—',
                      style: AppTextStyles.monoMedium.copyWith(color: colors.textPrimary),
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
                  color: colors.inkPanel,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROGRESS', style: AppTextStyles.overline.copyWith(color: colors.textHint)),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      totalChapters != null ? '$progressPercent%' : '—',
                      style: AppTextStyles.monoMedium.copyWith(
                        color: colors.goldSpark,
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
            backgroundColor: colors.inkBorder,
            valueColor: AlwaysStoppedAnimation<Color>(colors.goldSpark),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

/// Individual stepper button with scale animation on press
class _StepperButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    final isEnabled = widget.onTap != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: () {
                StorySyncHaptics.lightTap();
                widget.onTap?.call();
              },
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _isPressed ? colors.inkMuted : colors.inkPanel,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            border: Border.all(
              color: colors.inkBorder,
              width: AppDimensions.borderThin,
            ),
          ),
          child: Icon(
            widget.icon,
            color: isEnabled ? colors.textPrimary : colors.textHint,
            size: 20,
          ),
        ),
      ),
    );
  }
}
