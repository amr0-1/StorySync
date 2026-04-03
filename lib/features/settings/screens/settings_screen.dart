import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtrack/core/theme/app_colors.dart';
import 'package:mtrack/core/theme/app_dimensions.dart';
import 'package:mtrack/core/theme/app_text_styles.dart';

/// Settings screen with theme, data management, and account options
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkVoid,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.headlineMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // Appearance section
          _buildSectionLabel('APPEARANCE'),
          const SizedBox(height: AppDimensions.space12),
          _buildThemeSelector(),
          const SizedBox(height: AppDimensions.space24),

          // Data Management section
          _buildSectionLabel('DATA MANAGEMENT'),
          const SizedBox(height: AppDimensions.space12),
          _buildSettingsTile(
            icon: Icons.upload_file_rounded,
            title: 'Export Library',
            subtitle: 'Save backup to storage',
            onTap: _handleExport,
          ),
          const Divider(color: AppColors.inkBorder),
          _buildSettingsTile(
            icon: Icons.download_rounded,
            title: 'Import Library',
            subtitle: 'Restore from backup file',
            onTap: _handleImport,
          ),
          const Divider(color: AppColors.inkBorder),
          _buildSettingsTile(
            icon: Icons.image_not_supported_outlined,
            iconColor: AppColors.statusOnHold,
            title: 'Clear Image Cache',
            subtitle: 'Free up cached cover art',
            onTap: _handleClearCache,
          ),
          const SizedBox(height: AppDimensions.space24),

          // Account section
          _buildSectionLabel('ACCOUNT'),
          const SizedBox(height: AppDimensions.space12),
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            iconColor: AppColors.statusDropped,
            title: 'Sign Out',
            titleColor: AppColors.statusDropped,
            subtitle: 'Return to login screen',
            onTap: _handleSignOut,
          ),
          const SizedBox(height: AppDimensions.space32),

          // App info
          Center(
            child: Column(
              children: [
                Text(
                  'MTrack',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: AppDimensions.space4),
      child: Text(label, style: AppTextStyles.overline),
    );
  }

  Widget _buildThemeSelector() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space4),
      decoration: BoxDecoration(
        color: AppColors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: AppColors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Row(
        children: [
          _buildThemeOption(ThemeMode.system, 'System'),
          _buildThemeOption(ThemeMode.light, 'Light'),
          _buildThemeOption(ThemeMode.dark, 'Dark'),
        ],
      ),
    );
  }

  Widget _buildThemeOption(ThemeMode mode, String label) {
    final isSelected = _themeMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _themeMode = mode;
          });
          // TODO: Persist theme preference and update app
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.space12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.goldSpark : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? const Color(0xFF1A0F00)
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
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
        color: iconColor ?? AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      tileColor: AppColors.inkSurface,
    );
  }

  void _handleExport() {
    // TODO: Implement actual export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Export started...',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.inkPanel,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleImport() {
    // TODO: Implement actual import functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Select a backup file to import',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.inkPanel,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleClearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.inkPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        title: Text('Clear Image Cache?', style: AppTextStyles.titleLarge),
        content: Text(
          'This will remove all cached cover images. They will be re-downloaded as needed.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Clear actual image cache
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Image cache cleared',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  backgroundColor: AppColors.inkPanel,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Clear',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.statusOnHold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.inkPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        title: Text('Sign Out?', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to sign out? Your local library data will be preserved.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: Text(
              'Sign Out',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.statusDropped,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
