import 'package:flutter/material.dart';
import 'package:mtrack/core/models/reading_status.dart';
import 'package:mtrack/core/theme/app_colors.dart';
import 'package:mtrack/core/theme/app_dimensions.dart';
import 'package:mtrack/core/theme/app_text_styles.dart';

/// A badge displaying the reading status with appropriate colors
class StatusBadge extends StatelessWidget {
  /// The reading status to display
  final ReadingStatus status;

  /// Whether to use compact sizing
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.forStatus(status);
    final backgroundColor = AppColors.bgForStatus(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: AppDimensions.borderThin,
        ),
      ),
      child: Text(
        compact ? status.shortLabel : status.displayLabel,
        style: (compact ? AppTextStyles.overline : AppTextStyles.labelSmall)
            .copyWith(color: statusColor),
      ),
    );
  }
}
