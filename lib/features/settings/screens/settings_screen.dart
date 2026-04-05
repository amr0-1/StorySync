import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storysync/core/providers/theme_provider.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/core/utils/snackbar_util.dart';

/// Settings screen with theme, data management, and account options
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Scaffold(
      backgroundColor: colors.inkVoid,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.headlineMedium.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // Appearance section
          _buildSectionLabel(colors, 'APPEARANCE'),
          const SizedBox(height: AppDimensions.space12),
          _buildThemeSelector(colors),
          const SizedBox(height: AppDimensions.space24),

          // Data Management section
          _buildSectionLabel(colors, 'DATA MANAGEMENT'),
          const SizedBox(height: AppDimensions.space12),
          _buildSettingsTile(
            colors: colors,
            icon: Icons.upload_file_rounded,
            title: 'Export Library',
            subtitle: 'Save backup to storage',
            onTap: _handleExport,
          ),
          Divider(color: colors.inkBorder),
          _buildSettingsTile(
            colors: colors,
            icon: Icons.download_rounded,
            title: 'Import Library',
            subtitle: 'Restore from backup file',
            onTap: _handleImport,
          ),
          Divider(color: colors.inkBorder),
          _buildSettingsTile(
            colors: colors,
            icon: Icons.image_not_supported_outlined,
            iconColor: colors.statusOnHold,
            title: 'Clear Image Cache',
            subtitle: 'Free up cached cover art',
            onTap: _handleClearCache,
          ),
          const SizedBox(height: AppDimensions.space24),

          // Account section
          _buildSectionLabel(colors, 'ACCOUNT'),
          const SizedBox(height: AppDimensions.space12),
          _buildSettingsTile(
            colors: colors,
            icon: Icons.logout_rounded,
            iconColor: colors.statusDropped,
            title: 'Sign Out',
            titleColor: colors.statusDropped,
            subtitle: 'Return to login screen',
            onTap: _handleSignOut,
          ),
          const SizedBox(height: AppDimensions.space32),

          // App info
          Center(
            child: Column(
              children: [
                Text(
                  'StorySync',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(VoidInkColors colors, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: AppDimensions.space4),
      child: Text(
        label,
        style: AppTextStyles.overline.copyWith(color: colors.textHint),
      ),
    );
  }

  Widget _buildThemeSelector(VoidInkColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space4),
      decoration: BoxDecoration(
        color: colors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Row(
        children: [
          _buildThemeOption(colors, ThemeMode.system, 'System'),
          _buildThemeOption(colors, ThemeMode.light, 'Light'),
          _buildThemeOption(colors, ThemeMode.dark, 'Dark'),
        ],
      ),
    );
  }

  Widget _buildThemeOption(VoidInkColors colors, ThemeMode mode, String label) {
    final currentTheme = ref.watch(themeProvider);
    final isSelected = currentTheme == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(themeProvider.notifier).setThemeMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.space12),
          decoration: BoxDecoration(
            color: isSelected ? colors.goldSpark : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? const Color(0xFF1A0F00)
                    : colors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required VoidInkColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? colors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: titleColor ?? colors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      tileColor: colors.inkSurface,
    );
  }

  void _handleExport() {
    // TODO: Implement actual export functionality
    VoidInkSnackbar.showInfo(context, 'Export started...');
  }

  void _handleImport() {
    // TODO: Implement actual import functionality
    VoidInkSnackbar.showInfo(context, 'Select a backup file to import');
  }

  void _handleClearCache() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColors =
            Theme.of(dialogContext).extension<VoidInkColors>()!;
        return AlertDialog(
          backgroundColor: dialogColors.inkPanel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          title: Text(
            'Clear Image Cache?',
            style: AppTextStyles.titleLarge.copyWith(
              color: dialogColors.textPrimary,
            ),
          ),
          content: Text(
            'This will remove all cached cover images. They will be re-downloaded as needed.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: dialogColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: AppTextStyles.titleSmall.copyWith(
                  color: dialogColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // TODO: Clear actual image cache
                VoidInkSnackbar.showSuccess(context, 'Image cache cleared');
              },
              child: Text(
                'Clear',
                style: AppTextStyles.titleSmall.copyWith(
                  color: dialogColors.statusOnHold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColors =
            Theme.of(dialogContext).extension<VoidInkColors>()!;
        return AlertDialog(
          backgroundColor: dialogColors.inkPanel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          title: Text(
            'Sign Out?',
            style: AppTextStyles.titleLarge.copyWith(
              color: dialogColors.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out? Your local library data will be preserved.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: dialogColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: AppTextStyles.titleSmall.copyWith(
                  color: dialogColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.go('/login');
              },
              child: Text(
                'Sign Out',
                style: AppTextStyles.titleSmall.copyWith(
                  color: dialogColors.statusDropped,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
