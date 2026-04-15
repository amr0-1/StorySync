import 'package:flutter/services.dart';

class StorySyncHaptics {
  static bool _enabled = true;

  static void setEnabled(bool value) => _enabled = value;
  static bool get isEnabled => _enabled;

  static Future<void> lightTap() async {
    if (_enabled) await HapticFeedback.lightImpact();
  }

  static Future<void> mediumTap() async {
    if (_enabled) await HapticFeedback.mediumImpact();
  }

  static Future<void> heavyTap() async {
    if (_enabled) await HapticFeedback.heavyImpact();
  }

  static Future<void> selection() async {
    if (_enabled) await HapticFeedback.selectionClick();
  }
}
