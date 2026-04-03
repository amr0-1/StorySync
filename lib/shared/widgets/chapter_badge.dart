import 'package:flutter/material.dart';
import 'package:mtrack/core/theme/app_colors.dart';
import 'package:mtrack/core/theme/app_dimensions.dart';
import 'package:mtrack/core/theme/app_text_styles.dart';

/// A badge displaying the current chapter progress
class ChapterBadge extends StatelessWidget {
  /// The current chapter number
  final int current;

  /// The total number of chapters (optional)
  final int? total;

  const ChapterBadge({super.key, required this.current, this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xDD08080A), // 85% opaque inkVoid
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        border: Border.all(
          color: AppColors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Text(
        total != null ? '$current / $total' : '$current',
        style: AppTextStyles.monoSmall,
      ),
    );
  }
}
