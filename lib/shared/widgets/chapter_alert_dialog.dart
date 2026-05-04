import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';

class ChapterAlertDialog extends StatelessWidget {
  final String mangaTitle;
  final int currentChaptersRead;
  final VoidCallback onPastReading;
  final VoidCallback onCurrentPace;

  const ChapterAlertDialog({
    super.key,
    required this.mangaTitle,
    required this.currentChaptersRead,
    required this.onPastReading,
    required this.onCurrentPace,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String mangaTitle,
    required int currentChaptersRead,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChapterAlertDialog(
        mangaTitle: mangaTitle,
        currentChaptersRead: currentChaptersRead,
        onPastReading: () => context.pop(true),
        onCurrentPace: () => context.pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return AlertDialog(
      backgroundColor: colors.inkPanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        side: BorderSide(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.goldSpark, size: 24),
          const SizedBox(width: AppDimensions.space8),
          Text(
            'Whoa, that\'s a lot!',
            style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You\'ve read $currentChaptersRead chapters of "$mangaTitle" today.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
          Text(
            'Are you adding past reading history, or is this your current pace?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onPastReading,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space8,
            ),
            decoration: BoxDecoration(
              color: colors.inkSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              border: Border.all(color: colors.inkBorder),
            ),
            child: Text(
              'Past Reading',
              style: AppTextStyles.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        ElevatedButton(
          onPressed: onCurrentPace,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.goldSpark,
            foregroundColor: colors.inkVoid,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
          ),
          child: Text(
            'Current Pace',
            style: AppTextStyles.labelMedium.copyWith(color: colors.inkVoid),
          ),
        ),
      ],
    );
  }
}
