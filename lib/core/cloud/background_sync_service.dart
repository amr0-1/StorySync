import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:storysync/core/cloud/google_drive_service.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/core/providers/shared_prefs_provider.dart';

const String _autoSyncEnabledKey = 'autoSyncEnabled';
const String _autoSyncTaskName = 'storysync_cloud_backup';

final autoSyncEnabledProvider = StateNotifierProvider<AutoSyncNotifier, bool>((
  ref,
) {
  return AutoSyncNotifier(ref);
});

class AutoSyncNotifier extends StateNotifier<bool> {
  final Ref _ref;

  AutoSyncNotifier(this._ref) : super(false) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    state = prefs.getBool(_autoSyncEnabledKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setBool(_autoSyncEnabledKey, enabled);
    state = enabled;

    if (enabled) {
      await BackgroundSyncService.registerPeriodicTask();
    } else {
      await BackgroundSyncService.cancelPeriodicTask();
    }
  }
}

class BackgroundSyncService {
  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      _autoSyncTaskName,
      _autoSyncTaskName,
      frequency: const Duration(hours: 24),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }

  static Future<void> cancelPeriodicTask() async {
    await Workmanager().cancelByUniqueName(_autoSyncTaskName);
  }

  static Future<void> executeBackgroundSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_autoSyncEnabledKey) ?? false;

      if (!isEnabled) {
        return;
      }

      final driveService = GoogleDriveService();
      final isSignedIn = await driveService.signIn();

      if (!isSignedIn) {
        return;
      }

      final isarService = IsarService();
      final allManga = await isarService.getAllManga();

      final jsonData = allManga.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonData);

      await driveService.uploadBackup(jsonString);
      await driveService.signOut();
    } catch (e) {
      // Silent fail for background tasks
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _autoSyncTaskName) {
      await BackgroundSyncService.executeBackgroundSync();
    }
    return Future.value(true);
  });
}
