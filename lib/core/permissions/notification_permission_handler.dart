import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';

/// Handles runtime notification permission requests on Android 13+.
///
/// Flow:
/// 1. Check current permission status.
/// 2. If already granted → no-op.
/// 3. If not granted AND not permanently denied → show context-aware
///    bottom sheet explaining why, THEN request permission.
/// 4. If permanently denied → direct user to app settings.
///
/// Usage:
/// ```dart
/// await NotificationPermissionHandler.requestIfNeeded(context);
/// ```
class NotificationPermissionHandler {
  NotificationPermissionHandler._();

  /// Request notification permission with a context-aware explanation.
  ///
  /// Safe to call on any platform — silently no-ops on non-Android
  /// and pre-Android-13 devices.
  static Future<bool> requestIfNeeded(BuildContext context) async {
    // Only relevant on Android 13+ (API 33+)
    if (!Platform.isAndroid) return true;

    final status = await Permission.notification.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showSettingsSheet(context);
      }
      return false;
    }

    // Show explanation bottom sheet, then request
    if (context.mounted) {
      final shouldRequest = await _showExplanationSheet(context);
      if (shouldRequest) {
        final result = await Permission.notification.request();
        return result.isGranted;
      }
    }

    return false;
  }

  /// Context-aware bottom sheet explaining WHY notifications matter.
  ///
  /// Returns true if the user taps "Enable Notifications".
  static Future<bool> _showExplanationSheet(BuildContext context) async {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: colors.inkPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusMD),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.inkMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // Icon + Title
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.goldSpark.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSM,
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: colors.goldSpark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Text(
                    'Keep Your Streak Alive',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // Explanation
            Text(
              'StorySync uses notifications to remind you when your '
              'reading streak is at risk. We\'ll only nudge you at your '
              'peak reading time — never spam.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),

            // Benefits
            _BenefitRow(
              icon: Icons.local_fire_department_outlined,
              text: 'Streak protection reminders',
              colors: colors,
            ),
            _BenefitRow(
              icon: Icons.schedule_outlined,
              text: 'Timed to your reading habits',
              colors: colors,
            ),
            _BenefitRow(
              icon: Icons.do_not_disturb_alt_outlined,
              text: 'No marketing, ever',
              colors: colors,
            ),
            const SizedBox(height: AppDimensions.space24),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.goldSpark,
                  foregroundColor: colors.inkVoid,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSM,
                    ),
                  ),
                ),
                child: Text(
                  'Enable Notifications',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: colors.inkVoid,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Not Now',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textHint,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return result ?? false;
  }

  /// Bottom sheet for when permission is permanently denied.
  ///
  /// Directs the user to the system app settings page.
  static Future<void> _showSettingsSheet(BuildContext context) async {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    await showModalBottomSheet(
      context: context,
      backgroundColor: colors.inkPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusMD),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.inkMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
            Text(
              'Notifications Disabled',
              style: AppTextStyles.titleLarge.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.space12),
            Text(
              'Notification permission was previously denied. '
              'To enable streak reminders, please open Settings '
              'and grant notification access to StorySync.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.goldSpark,
                  side: BorderSide(color: colors.goldSpark),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSM,
                    ),
                  ),
                ),
                child: Text(
                  'Open Settings',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: colors.goldSpark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Maybe Later',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textHint,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small benefit row with icon + text for the explanation sheet.
class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidInkColors colors;

  const _BenefitRow({
    required this.icon,
    required this.text,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.goldDim),
          const SizedBox(width: AppDimensions.space8),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
