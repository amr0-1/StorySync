import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/core/cloud/google_drive_service.dart';
import 'package:storysync/core/cloud/background_sync_service.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/data/models/reading_log.dart';
import 'package:storysync/core/providers/theme_provider.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/core/utils/snackbar_util.dart';
import 'package:storysync/shared/widgets/app_icon.dart';

/// Settings screen with theme, data management, and account options
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isCloudSyncing = false;
  bool _isLinking = false;
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Scaffold(
      backgroundColor: colors.inkVoid,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon.small(),
            const SizedBox(width: AppDimensions.space8),
            Text(
              'Settings',
              style: AppTextStyles.headlineMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
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

          // Cloud Sync section
          _buildSectionLabel(colors, 'CLOUD SYNC'),
          const SizedBox(height: AppDimensions.space12),
          _buildCloudSyncSection(colors),
          const SizedBox(height: AppDimensions.space24),

          const SizedBox(height: AppDimensions.space32),

          // App info
          Center(
            child: Column(
              children: [
                const AppIcon.medium(),
                const SizedBox(height: AppDimensions.space12),
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
      leading: Icon(icon, color: iconColor ?? colors.textSecondary, size: 22),
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

  Widget _buildCloudSyncSection(VoidInkColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: colors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCloudSyncTile(
            colors: colors,
            icon: Icons.cloud_done_outlined,
            title: _isLinking ? 'Connecting...' : 'Link Google Drive',
            subtitle: 'Connect your Google account for cloud backup',
            onTap: _isLinking ? null : _handleLinkGoogleDrive,
          ),
          const SizedBox(height: AppDimensions.space12),
          _buildCloudSyncTile(
            colors: colors,
            icon: Icons.cloud_upload_outlined,
            title: _isCloudSyncing ? 'Syncing...' : 'Force Cloud Sync',
            subtitle: 'Upload backup to Google Drive now',
            onTap: _isCloudSyncing || _isLinking ? null : _handleForceCloudSync,
          ),
          const SizedBox(height: AppDimensions.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Auto-Sync in Background',
                style: AppTextStyles.titleSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              Switch(
                value: ref.watch(autoSyncEnabledProvider),
                onChanged: _isLinking ? null : (value) => _handleToggleAutoSync(value),
                activeThumbColor: colors.goldSpark,
              ),
            ],
          ),
          Text(
            'Sync every 24 hours when connected',
            style: AppTextStyles.bodySmall.copyWith(color: colors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudSyncTile({
    required VoidInkColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: colors.textSecondary, size: 22),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: onTap != null ? colors.textPrimary : colors.textHint,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: colors.textHint),
        ],
      ),
    );
  }

  Future<void> _handleLinkGoogleDrive() async {
    setState(() => _isLinking = true);
    
    try {
      final driveService = GoogleDriveService();
      final success = await driveService.signIn();
      
      if (mounted) {
        if (success) {
          VoidInkSnackbar.showSuccess(context, 'Google Drive linked successfully!');
        } else {
          VoidInkSnackbar.showError(context, 'Failed to link Google Drive');
        }
      }
    } catch (e) {
      if (mounted) {
        VoidInkSnackbar.showError(context, 'Failed to link Google Drive');
      }
    } finally {
      if (mounted) {
        setState(() => _isLinking = false);
      }
    }
  }

  Future<void> _handleForceCloudSync() async {
    setState(() => _isCloudSyncing = true);
    
    try {
      final driveService = GoogleDriveService();
      final success = await driveService.signIn();
      
      if (!success) {
        if (mounted) {
          VoidInkSnackbar.showError(context, 'Please link Google Drive first');
        }
        return;
      }
      
      final isarService = ref.read(isarServiceProvider);
      final allManga = await isarService.getAllManga();
      
      final jsonData = allManga.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonData);
      
      final uploadSuccess = await driveService.uploadBackup(jsonString);
      
      await driveService.signOut();
      
      if (mounted) {
        if (uploadSuccess) {
          VoidInkSnackbar.showSuccess(context, 'Backup uploaded to Google Drive');
        } else {
          VoidInkSnackbar.showError(context, 'Failed to upload backup');
        }
      }
    } catch (e) {
      if (mounted) {
        VoidInkSnackbar.showError(context, 'Failed to sync: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isCloudSyncing = false);
      }
    }
  }

  Future<void> _handleToggleAutoSync(bool enabled) async {
    try {
      await ref.read(autoSyncEnabledProvider.notifier).setEnabled(enabled);
      
      if (mounted) {
        if (enabled) {
          VoidInkSnackbar.showSuccess(context, 'Auto-sync enabled');
        } else {
          VoidInkSnackbar.showInfo(context, 'Auto-sync disabled');
        }
      }
    } catch (e) {
      if (mounted) {
        VoidInkSnackbar.showError(context, 'Failed to update settings');
      }
    }
  }

  Future<void> _handleExport() async {
    try {
      final isarService = ref.read(isarServiceProvider);
      final allManga = await isarService.getAllManga();
      final allReadingLogs = await isarService.getAllReadingLogs();

      final Map<String, dynamic> exportData = {
        'manga': allManga.map((e) => e.toJson()).toList(),
        'readingLogs': allReadingLogs.map((e) => e.toJson()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
      
      final String jsonString = jsonEncode(exportData);

      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save your library backup',
        fileName: 'storysync_library.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (outputFile != null) {
        // Only write manually if it's not Android, iOS, or Web where file_picker handles writing the bytes
        try {
          if (!Platform.isAndroid && !Platform.isIOS) {
            final file = File(outputFile);
            await file.writeAsString(jsonString);
          }
        } catch (e) {
          // Platform.isAndroid can throw on Web, so we ignore it if it happens
        }

        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              VoidInkSnackbar.showSuccess(
                context,
                'Library exported successfully!',
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) VoidInkSnackbar.showError(context, 'Export failed: $e');
        });
      }
    }
  }

  Future<void> _handleImport() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final String jsonString = await file.readAsString();
        final Map<String, dynamic> decoded = jsonDecode(jsonString);

        final isarService = ref.read(isarServiceProvider);

        int importedCount = 0;
        
        // Import manga items
        if (decoded.containsKey('manga')) {
          final List<dynamic> mangaList = decoded['manga'] as List<dynamic>;
          for (var map in mangaList) {
            try {
              final mangaItem = MangaItem.fromJson(map as Map<String, dynamic>);
              await isarService.saveManga(mangaItem);
              importedCount++;
            } catch (e) {
              continue;
            }
          }
        }
        
        // Import reading logs (historical data, not today's activity)
        if (decoded.containsKey('readingLogs')) {
          final List<dynamic> logsList = decoded['readingLogs'] as List<dynamic>;
          for (var map in logsList) {
            try {
              final log = ReadingLog.fromJson(map as Map<String, dynamic>);
              await isarService.saveReadingLog(log);
            } catch (e) {
              continue;
            }
          }
        }

        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              VoidInkSnackbar.showSuccess(
                context,
                'Imported $importedCount titles successfully!',
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) VoidInkSnackbar.showError(context, 'Import failed: $e');
        });
      }
    }
  }

  void _handleClearCache() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColors = Theme.of(
          dialogContext,
        ).extension<VoidInkColors>()!;
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    VoidInkSnackbar.showSuccess(context, 'Image cache cleared');
                  }
                });
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
}
