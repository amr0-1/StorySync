import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:storysync/core/database/isar_service.dart';
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

          // Developer & About section
          _buildSectionLabel(colors, 'DEVELOPER & ABOUT'),
          const SizedBox(height: AppDimensions.space12),
          _buildSettingsTile(
            colors: colors,
            icon: Icons.code,
            title: 'Developer',
            subtitle: '@amr0-1',
            onTap: () async {
              final url = Uri.parse('https://github.com/amr0-1');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
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
                const SizedBox(height: AppDimensions.space4),
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
                color: isSelected ? colors.inkVoid : colors.textSecondary,
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

  Future<void> _handleExport() async {
    try {
      final isarService = ref.read(isarServiceProvider);
      final allManga = await isarService.getAllManga();
      final allReadingLogs = await isarService.getAllReadingLogs();

      final Map<String, dynamic> exportData = {
        'manga': allManga.map((e) => e.toJson()).toList(),
        'readingLogs': allReadingLogs.map((e) => e.toJson()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '2.0.0',
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

        int importedMangaCount = 0;
        int importedLogCount = 0;

        // ── Step 1: Upsert all MangaItems first ────────────────
        final Set<String> validMangaDexIds = {};
        if (decoded.containsKey('manga')) {
          final List<dynamic> mangaList = decoded['manga'] as List<dynamic>;
          for (var map in mangaList) {
            try {
              final mangaItem = MangaItem.fromJson(map as Map<String, dynamic>);
              await isarService.saveManga(mangaItem);
              validMangaDexIds.add(mangaItem.mangaDexId);
              importedMangaCount++;
            } catch (e) {
              continue;
            }
          }
        }

        // ── Step 2: Restore reading logs with integrity check ──
        // Only imports logs whose mangaDexId references a valid MangaItem.
        // Preserves original isImported/isPastReading flags so analytics
        // mirrors the original state exactly after a backup→restore cycle.
        if (decoded.containsKey('readingLogs')) {
          final List<dynamic> logsList =
              decoded['readingLogs'] as List<dynamic>;
          final List<ReadingLog> logs = [];
          for (var map in logsList) {
            try {
              logs.add(ReadingLog.fromJson(map as Map<String, dynamic>));
            } catch (e) {
              continue;
            }
          }

          if (logs.isNotEmpty) {
            importedLogCount = await isarService
                .restoreReadingLogsWithIntegrity(logs, validMangaDexIds);
          }
        }

        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              VoidInkSnackbar.showSuccess(
                context,
                'Imported $importedMangaCount titles & $importedLogCount logs',
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
              onPressed: () => dialogContext.pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.titleSmall.copyWith(
                  color: dialogColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                dialogContext.pop();
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
