import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier that manages the app's theme mode
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Default to system theme
    return ThemeMode.system;
  }

  /// Update the theme mode
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

/// Provider for the app's theme mode
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
