import 'package:flutter/material.dart';

/// Void Ink typography styles.
///
/// Colors are intentionally omitted from these base definitions.
/// They are applied dynamically via [ThemeData.textTheme] in `AppTheme`,
/// which injects the correct colors from `VoidInkColors` for each brightness.
///
/// When using these styles directly in widgets, apply color via:
/// ```dart
/// final colors = Theme.of(context).extension<VoidInkColors>()!;
/// Text('Hello', style: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary));
/// ```
abstract class AppTextStyles {

  // ── Display (Cormorant Garamond) ────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'CormorantGaramond',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: 0.3,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'CormorantGaramond',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.15,
  );

  // ── Headlines (Cormorant Garamond) ──────────────────────────
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'CormorantGaramond',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'CormorantGaramond',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  // ── Titles (DM Sans) ────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  // ── Body (DM Sans) ──────────────────────────────────────────
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Labels (DM Sans) ────────────────────────────────────────
  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  // ── Mono / Stats (JetBrains Mono) ───────────────────────────
  static const TextStyle monoLarge = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 28,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.5,
  );

  static const TextStyle monoMedium = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle monoSmall = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  // ── Tag / Overline ───────────────────────────────────────────
  static const TextStyle overline = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.0,
  );
}
