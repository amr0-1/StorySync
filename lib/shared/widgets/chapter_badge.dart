import 'package:flutter/material.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';

/// A badge displaying the current chapter progress
class ChapterBadge extends StatelessWidget {
  /// The current chapter number
  final int current;

  /// The total number of chapters (optional)
  final int? total;

  const ChapterBadge({super.key, required this.current, this.total});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: colors.inkVoid.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Text(
        total != null ? '$current / $total' : '$current',
        style: AppTextStyles.monoSmall.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
