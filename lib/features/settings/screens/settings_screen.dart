import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:share_plus/share_plus.dart';
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
import 'package:storysync/core/providers/walkthrough_keys_provider.dart';
import 'package:storysync/core/providers/database_state_provider.dart';
import 'package:storysync/features/library/presentation/controllers/library_controller.dart';

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
                  'Version 1.2.0',
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
      // Step 1: Resolve paths on the main thread (lightweight, no object graphs)
      final isarService = ref.read(isarServiceProvider);
      final dbDirectory = await isarService.getDbDirectory();

      // Step 2: Write to a temp file inside the app's own directory first.
      // This avoids SAF/content-URI issues on Android where File() can't
      // write to picker-returned URIs directly.
      final tempFilePath = '$dbDirectory/storysync_export_tmp.json';

      // Step 3: Launch the hardened isolate worker — only primitives cross the boundary
      final bool success = await Isolate.run(
        () => _exportWorker(dbDirectory, tempFilePath),
      );

      if (!success) throw Exception('Isolate worker returned failure');

      final tempFile = File(tempFilePath);
      if (!await tempFile.exists()) throw Exception('Export file missing');

      // Step 4: The Native Stream Handoff (Zero RAM impact)
      // On mobile we pass the URI path, NOT the bytes. The OS handles
      // the heavy lifting via the native share sheet.
      if (Platform.isAndroid || Platform.isIOS) {
        final xFile = XFile(tempFilePath, mimeType: 'application/json');
        await SharePlus.instance.share(
          ShareParams(
            files: [xFile],
            subject: 'StorySync Library Backup',
            text: 'storysync_library.json',
          ),
        );
      } else {
        // Desktop fallback — FilePicker for a direct file copy
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save your library backup',
          fileName: 'storysync_library.json',
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (outputFile != null) {
          await tempFile.copy(outputFile);
        }
      }

      if (mounted) {
        VoidInkSnackbar.showSuccess(context, 'Library prepared for export!');
      }
    } catch (e) {
      if (mounted) {
        VoidInkSnackbar.showError(context, 'Export failed: $e');
      }
    }
  }

  Future<void> _handleImport() async {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final pureFilePath = result.files.single.path!;

        if (!mounted) return;

        // ---------------------------------------------------------
        // FIX: THE YIELD MUST COME FIRST
        // Force the main thread to idle so the Android OS can fully
        // recreate the Vulkan graphics surface. Do absolutely NOTHING
        // with the UI or State until this completes.
        // ---------------------------------------------------------
        await Future.delayed(const Duration(milliseconds: 600));

        if (!mounted) return;

        // 1. ENGAGE BLINDFOLD: Tell all Riverpod streams to shut down
        ref.read(isRestoringDatabaseProvider.notifier).state = true;

        // 2. NOW IT IS SAFE TO PAINT THE UI
        _showRestoreLoadingOverlay();

        // 3. LAUNCH THE ISOLATE (Using the pure top-level wrapper)
        final BackupData backup = await processBackupInIsolate(pureFilePath);

        final isar = await ref.read(isarServiceProvider).openDB();

        // 4. BATCH INSERTS ON MAIN THREAD (I/O Heavy - Handled async by Isar)
        await clearRestoredDatabase(isar);

        const batchSize = 250;

        if (backup.manga.isNotEmpty) {
          for (var i = 0; i < backup.manga.length; i += batchSize) {
            final end = (i + batchSize < backup.manga.length)
                ? i + batchSize
                : backup.manga.length;
            final batch = backup.manga.sublist(i, end);

            // Use async writeTxn and putAll. This allows Isar to handle the DB
            // lock asynchronously without halting the Flutter event loop.
            await restoreMangaBatch(isar, batch);

            // The micro-yield allows Riverpod watchers to process the new data
            // and the UI to render frames before the next batch locks the DB.
            await Future.delayed(const Duration(milliseconds: 16));
          }
        }

        if (backup.logs.isNotEmpty) {
          for (var i = 0; i < backup.logs.length; i += batchSize) {
            final end = (i + batchSize < backup.logs.length)
                ? i + batchSize
                : backup.logs.length;
            final batch = backup.logs.sublist(i, end);

            await restoreReadingLogBatch(isar, batch);

            await Future.delayed(const Duration(milliseconds: 16));
          }
        }

        // Remove blindfold and force fresh UI rebuild
        ref.read(isRestoringDatabaseProvider.notifier).state = false;

        if (mounted && rootNavigator.canPop()) {
          rootNavigator.pop();
        }

        ref.invalidate(isarInitProvider);
        resetWalkthroughKeys(ref);
        ref.invalidate(libraryControllerProvider);

        if (mounted) {
          VoidInkSnackbar.showSuccess(
            context,
            'Library restored successfully!',
          );
        }
      }
    } catch (e, st) {
      debugPrint('DEBUG: Restore error: $e\n$st');
      if (mounted && rootNavigator.canPop()) {
        rootNavigator.pop();
      }
      ref.read(isRestoringDatabaseProvider.notifier).state = false;

      if (mounted) {
        VoidInkSnackbar.showError(
          context,
          'Restore failed: Corrupted file or database lock.',
        );
      }
    }
  }

  /// Shows a non-dismissible loading overlay during restore.
  void _showRestoreLoadingOverlay() {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.space24),
            decoration: BoxDecoration(
              color: colors.inkSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(
                color: colors.inkBorder,
                width: AppDimensions.borderThin,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colors.goldSpark),
                  strokeWidth: 2,
                ),
                const SizedBox(height: AppDimensions.space16),
                Text(
                  'Restoring backup…',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  'Do not close the app',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

// ============================================================
// HARDENED EXPORT WORKER — Runs entirely in a background isolate.
// ============================================================
//
// Accepts only primitive strings (dbDirectory, targetFilePath) so
// zero heavyweight objects cross the isolate boundary.
//
// Architecture:
//   1. Opens its own Isar instance synchronously (background-safe).
//   2. Queries all data with findAllSync() — no async overhead.
//   3. Streams JSON directly to disk via JsonUtf8Encoder, bypassing
//      the massive contiguous String allocation from jsonEncode().
//   4. Returns a simple bool across the boundary.
//   5. Isar.close() is guaranteed in a finally block to prevent
//      native Rust thread deadlocks.
// ============================================================
Future<bool> _exportWorker(String dbDirectory, String targetFilePath) async {
  Isar? isar;
  try {
    // 1. Open a background-only Isar instance synchronously
    isar = Isar.openSync(
      [MangaItemSchema, ReadingLogSchema],
      directory: dbDirectory,
      name: 'storysync_db',
    );

    // 2. Execute findAllSync() queries — entire object graph stays in-isolate
    final allManga = isar.mangaItems
        .where()
        .sortByLastUpdatedDesc()
        .findAllSync();
    final allReadingLogs = isar.readingLogs.where().findAllSync();

    // 3. Map to plain Dart Maps (JSON-serializable, no Isar proxies)
    final Map<String, dynamic> exportData = {
      'manga': allManga.map((e) => e.toJson()).toList(),
      'readingLogs': allReadingLogs.map((e) => e.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '2.0.0',
    };

    // 4. CRITICAL: Stream JSON directly to disk via JsonUtf8Encoder.
    //    This bypasses the massive contiguous string allocation that
    //    jsonEncode() creates, which was the root cause of the OOM crash.
    final sink = File(targetFilePath).openWrite();
    await Stream<Object?>.value(
      exportData,
    ).transform(JsonUtf8Encoder()).pipe(sink);

    return true;
  } catch (e) {
    // USE standard print() IN ISOLATES! debugPrint can crash isolates.
    // ignore: avoid_print
    print('Export worker error: $e');
    return false;
  } finally {
    // 5. ALWAYS close Isar to prevent native Rust thread deadlocks
    isar?.close();
  }
}

// A simple container class to return both lists from the isolate.
class BackupData {
  final List<MangaItem> manga;
  final List<ReadingLog> logs;
  BackupData(this.manga, this.logs);
}

Future<BackupData> processBackupInIsolate(String filePath) {
  // This top-level wrapper only captures the file path string.
  return Isolate.run(() => parseBackupData(filePath));
}

Future<void> clearRestoredDatabase(Isar isar) {
  return isar.writeTxn(() async {
    await isar.clear();
  });
}

Future<void> restoreMangaBatch(Isar isar, List<MangaItem> batch) {
  return isar.writeTxn(() async {
    await isar.mangaItems.putAll(batch);
  });
}

Future<void> restoreReadingLogBatch(Isar isar, List<ReadingLog> batch) {
  return isar.writeTxn(() async {
    await isar.readingLogs.putAll(batch);
  });
}

// Completely outside any class to be a pure top-level function
Future<BackupData> parseBackupData(String filePath) async {
  final String jsonString = await File(filePath).readAsString();
  final Map<String, dynamic> decoded = jsonDecode(jsonString);

  List<MangaItem> parsedManga = [];
  List<ReadingLog> parsedLogs = [];
  final Set<String> validMangaDexIds = {};

  if (decoded.containsKey('manga')) {
    for (var map in decoded['manga'] as List<dynamic>) {
      try {
        final mangaMap = map as Map<String, dynamic>;

        // BACKWARD COMPATIBILITY FIX:
        // Manually inject default values for new/legacy fields if they are missing
        mangaMap['mangaDexId'] = mangaMap['mangaDexId'] ?? '';
        mangaMap['title'] = mangaMap['title'] ?? 'Unknown Title';
        mangaMap['source'] = mangaMap['source'] ?? 'mangadex';
        mangaMap['hasCustomMetadata'] = mangaMap['hasCustomMetadata'] ?? false;
        mangaMap['chapterProgress'] = mangaMap['chapterProgress'] ?? 0;
        mangaMap['readingStatus'] = mangaMap['readingStatus'] ?? 'planToRead';

        if ((mangaMap['mangaDexId'] as String).isEmpty) {
          continue;
        }

        final item = MangaItem.fromJson(mangaMap);
        parsedManga.add(item);
        validMangaDexIds.add(item.mangaDexId);
      } catch (e, st) {
        // USE standard print() IN ISOLATES! debugPrint can crash isolates.
        // ignore: avoid_print
        print('Skipping outdated/corrupted MangaItem: $e\n$st');
        continue;
      }
    }
  }

  if (decoded.containsKey('readingLogs')) {
    for (var map in decoded['readingLogs'] as List<dynamic>) {
      try {
        final logMap = map as Map<String, dynamic>;

        // Inject default values for readingLog fields
        logMap['date'] = logMap['date'] ?? DateTime.now().toIso8601String();
        logMap['mangaDexId'] = logMap['mangaDexId'] ?? '';
        logMap['chaptersRead'] = logMap['chaptersRead'] ?? 1;
        logMap['sessionDurationMinutes'] =
            logMap['sessionDurationMinutes'] ?? 0;
        logMap['isImported'] = logMap['isImported'] ?? false;
        logMap['isPastReading'] = logMap['isPastReading'] ?? false;

        if ((logMap['mangaDexId'] as String).isEmpty) {
          continue;
        }

        final log = ReadingLog.fromJson(logMap);
        if (validMangaDexIds.contains(log.mangaDexId)) {
          parsedLogs.add(log);
        }
      } catch (e, st) {
        // USE standard print() IN ISOLATES! debugPrint can crash isolates.
        // ignore: avoid_print
        print('Skipping outdated/corrupted ReadingLog: $e\n$st');
        continue;
      }
    }
  }

  return BackupData(parsedManga, parsedLogs);
}
