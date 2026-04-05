import 'package:flutter/material.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';

/// Utility class for displaying premium Void Ink styled snackbars
abstract class VoidInkSnackbar {
  /// Show a success snackbar with gold accent
  static void showSuccess(BuildContext context, String message) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    _showSnackbar(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      accentColor: colors.goldSpark,
    );
  }

  /// Show an error snackbar with red accent
  static void showError(BuildContext context, String message) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    _showSnackbar(
      context,
      message: message,
      icon: Icons.error_rounded,
      accentColor: colors.statusDropped,
    );
  }

  /// Show an info snackbar with teal accent
  static void showInfo(BuildContext context, String message) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    _showSnackbar(
      context,
      message: message,
      icon: Icons.info_rounded,
      accentColor: colors.statusReading,
    );
  }

  static void _showSnackbar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color accentColor,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _VoidInkSnackbarContent(
          message: message,
          icon: icon,
          accentColor: accentColor,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space12,
        ),
      ),
    );
  }
}

/// Custom snackbar content with Void Ink styling
class _VoidInkSnackbarContent extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color accentColor;

  const _VoidInkSnackbarContent({
    required this.message,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.inkPanel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Gold accent line on left edge
          Container(width: 3, height: 48, color: accentColor),
          const SizedBox(width: AppDimensions.space12),
          // Icon
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(width: AppDimensions.space8),
          // Message
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.space12,
              ),
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
        ],
      ),
    );
  }
}
