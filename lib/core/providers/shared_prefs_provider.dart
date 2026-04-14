import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the SharedPreferences singleton instance.
/// This must be overridden in the ProviderScope at the root of the app.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

/// Provider that exposes the first-run status.
/// Defaults to true if the key doesn't exist.
final isFirstRunProvider = StateNotifierProvider<FirstRunNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FirstRunNotifier(prefs);
});

class FirstRunNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'storysync_is_first_run';

  FirstRunNotifier(this._prefs) : super(_prefs.getBool(_key) ?? true);

  Future<void> setFirstRunCompleted() async {
    await _prefs.setBool(_key, false);
    state = false;
  }
}
