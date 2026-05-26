import 'package:flutter/material.dart';
import 'package:storysync/core/models/reading_status.dart';

/// VoidInkColors — Dynamic theme colors with smooth transitions.
///
/// Access in any widget via:
/// ```dart
/// final colors = Theme.of(context).extension<VoidInkColors>()!;
/// ```
///
/// All custom colors participate in Flutter's built-in 200ms theme
/// crossfade because [lerp] is fully implemented.
@immutable
class VoidInkColors extends ThemeExtension<VoidInkColors> {
  // ── Backgrounds ────────────────────────────────────────────
  final Color inkVoid;
  final Color inkSurface;
  final Color inkPanel;
  final Color inkBorder;
  final Color inkMuted;

  // ── Gold Accent ─────────────────────────────────────────────
  final Color goldSpark;
  final Color goldLight;
  final Color goldDim;

  // ── Text ────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  // ── Status Colors ───────────────────────────────────────────
  final Color statusReading;
  final Color statusCompleted;
  final Color statusOnHold;
  final Color statusPlanToRead;
  final Color statusDropped;

  // ── Status Background Tints ─────────────────────────────────
  final Color statusReadingBg;
  final Color statusCompletedBg;
  final Color statusOnHoldBg;
  final Color statusPlanToReadBg;
  final Color statusDroppedBg;

  const VoidInkColors({
    required this.inkVoid,
    required this.inkSurface,
    required this.inkPanel,
    required this.inkBorder,
    required this.inkMuted,
    required this.goldSpark,
    required this.goldLight,
    required this.goldDim,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.statusReading,
    required this.statusCompleted,
    required this.statusOnHold,
    required this.statusPlanToRead,
    required this.statusDropped,
    required this.statusReadingBg,
    required this.statusCompletedBg,
    required this.statusOnHoldBg,
    required this.statusPlanToReadBg,
    required this.statusDroppedBg,
  });

  /// Dark theme colors — Void Ink palette
  static const dark = VoidInkColors(
    // Backgrounds
    inkVoid: Color(0xFF08080A),
    inkSurface: Color(0xFF111115),
    inkPanel: Color(0xFF1C1C22),
    inkBorder: Color(0xFF28282F),
    inkMuted: Color(0xFF3D3D46),
    // Gold Accent
    goldSpark: Color(0xFFE8A43F),
    goldLight: Color(0xFFF5C878),
    goldDim: Color(0xFF9A6B1F),
    // Text
    textPrimary: Color(0xFFF2EEE8),
    textSecondary: Color(0xFF9B978F),
    textHint: Color(0xFF58565A),
    // Status
    statusReading: Color(0xFF1FC8A0),
    statusCompleted: Color(0xFF52C27A),
    statusOnHold: Color(0xFFE8A43F),
    statusPlanToRead: Color(0xFF9178E8),
    statusDropped: Color(0xFFE85A5A),
    // Status backgrounds (12% opacity)
    statusReadingBg: Color(0x1F1FC8A0),
    statusCompletedBg: Color(0x1F52C27A),
    statusOnHoldBg: Color(0x1FE8A43F),
    statusPlanToReadBg: Color(0x1F9178E8),
    statusDroppedBg: Color(0x1FE85A5A),
  );

  /// Light theme colors — Ceramic & Brushed Steel palette
  static const light = VoidInkColors(
    // Backgrounds
    inkVoid: Color(0xFFFAFAF8),
    inkSurface: Color(0xFFFFFFFF),
    inkPanel: Color(0xFFF0F0EE),
    inkBorder: Color(0xFFE2E2DE),
    inkMuted: Color(0xFFD5D5D1),
    // Gold Accent — deepened for contrast on light backgrounds
    goldSpark: Color(0xFFD48D2A),
    goldLight: Color(0xFFB0701C),
    goldDim: Color(0xFFE8C28F),
    // Text
    textPrimary: Color(0xFF18181A),
    textSecondary: Color(0xFF5A5A60),
    textHint: Color(0xFF8C8C91),
    // Status — same hues, untouched
    statusReading: Color(0xFF1FC8A0),
    statusCompleted: Color(0xFF52C27A),
    statusOnHold: Color(0xFFE8A43F),
    statusPlanToRead: Color(0xFF9178E8),
    statusDropped: Color(0xFFE85A5A),
    // Status backgrounds (10% / 0x1A opacity for cleaner look on white)
    statusReadingBg: Color(0x1A1FC8A0),
    statusCompletedBg: Color(0x1A52C27A),
    statusOnHoldBg: Color(0x1AE8A43F),
    statusPlanToReadBg: Color(0x1A9178E8),
    statusDroppedBg: Color(0x1AE85A5A),
  );

  /// Returns the foreground color for a given reading status.
  Color forStatus(ReadingStatus status) => switch (status) {
    ReadingStatus.reading => statusReading,
    ReadingStatus.completed => statusCompleted,
    ReadingStatus.onHold => statusOnHold,
    ReadingStatus.planToRead => statusPlanToRead,
    ReadingStatus.dropped => statusDropped,
  };

  /// Returns the background tint for a given reading status.
  Color bgForStatus(ReadingStatus status) => switch (status) {
    ReadingStatus.reading => statusReadingBg,
    ReadingStatus.completed => statusCompletedBg,
    ReadingStatus.onHold => statusOnHoldBg,
    ReadingStatus.planToRead => statusPlanToReadBg,
    ReadingStatus.dropped => statusDroppedBg,
  };

  // ── Adaptive State Variants ──────────────────────────────────

  /// Subtle vibrant variant for "Hot / Binge" state (Efficiency > 80).
  ///
  /// Increases gold accent saturation by ~8%. All other colors remain
  /// identical — preserving the Void Ink identity.
  VoidInkColors get vibrant => copyWith(
    goldSpark: _adjustSaturation(goldSpark, 0.08),
    goldLight: _adjustSaturation(goldLight, 0.05),
  );

  /// Subtle muted variant for "Fatigued / Inactive" state.
  ///
  /// Softens accent colors by ~10% and reduces text contrast slightly.
  /// The effect is intentionally near-imperceptible — a subconscious shift.
  VoidInkColors get muted => copyWith(
    goldSpark: _adjustSaturation(goldSpark, -0.10),
    goldLight: _adjustSaturation(goldLight, -0.08),
    textPrimary: Color.lerp(textPrimary, textSecondary, 0.10)!,
    inkBorder: Color.lerp(inkBorder, inkMuted, 0.15)!,
  );

  /// Shift a color's saturation by [delta] in HSL space.
  /// Positive delta = richer, negative delta = more muted.
  static Color _adjustSaturation(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withSaturation((hsl.saturation + delta).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  VoidInkColors copyWith({
    Color? inkVoid,
    Color? inkSurface,
    Color? inkPanel,
    Color? inkBorder,
    Color? inkMuted,
    Color? goldSpark,
    Color? goldLight,
    Color? goldDim,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? statusReading,
    Color? statusCompleted,
    Color? statusOnHold,
    Color? statusPlanToRead,
    Color? statusDropped,
    Color? statusReadingBg,
    Color? statusCompletedBg,
    Color? statusOnHoldBg,
    Color? statusPlanToReadBg,
    Color? statusDroppedBg,
  }) {
    return VoidInkColors(
      inkVoid: inkVoid ?? this.inkVoid,
      inkSurface: inkSurface ?? this.inkSurface,
      inkPanel: inkPanel ?? this.inkPanel,
      inkBorder: inkBorder ?? this.inkBorder,
      inkMuted: inkMuted ?? this.inkMuted,
      goldSpark: goldSpark ?? this.goldSpark,
      goldLight: goldLight ?? this.goldLight,
      goldDim: goldDim ?? this.goldDim,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      statusReading: statusReading ?? this.statusReading,
      statusCompleted: statusCompleted ?? this.statusCompleted,
      statusOnHold: statusOnHold ?? this.statusOnHold,
      statusPlanToRead: statusPlanToRead ?? this.statusPlanToRead,
      statusDropped: statusDropped ?? this.statusDropped,
      statusReadingBg: statusReadingBg ?? this.statusReadingBg,
      statusCompletedBg: statusCompletedBg ?? this.statusCompletedBg,
      statusOnHoldBg: statusOnHoldBg ?? this.statusOnHoldBg,
      statusPlanToReadBg: statusPlanToReadBg ?? this.statusPlanToReadBg,
      statusDroppedBg: statusDroppedBg ?? this.statusDroppedBg,
    );
  }

  @override
  VoidInkColors lerp(VoidInkColors? other, double t) {
    if (other is! VoidInkColors) return this;
    return VoidInkColors(
      inkVoid: Color.lerp(inkVoid, other.inkVoid, t)!,
      inkSurface: Color.lerp(inkSurface, other.inkSurface, t)!,
      inkPanel: Color.lerp(inkPanel, other.inkPanel, t)!,
      inkBorder: Color.lerp(inkBorder, other.inkBorder, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      goldSpark: Color.lerp(goldSpark, other.goldSpark, t)!,
      goldLight: Color.lerp(goldLight, other.goldLight, t)!,
      goldDim: Color.lerp(goldDim, other.goldDim, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      statusReading: Color.lerp(statusReading, other.statusReading, t)!,
      statusCompleted: Color.lerp(statusCompleted, other.statusCompleted, t)!,
      statusOnHold: Color.lerp(statusOnHold, other.statusOnHold, t)!,
      statusPlanToRead: Color.lerp(
        statusPlanToRead,
        other.statusPlanToRead,
        t,
      )!,
      statusDropped: Color.lerp(statusDropped, other.statusDropped, t)!,
      statusReadingBg: Color.lerp(statusReadingBg, other.statusReadingBg, t)!,
      statusCompletedBg: Color.lerp(
        statusCompletedBg,
        other.statusCompletedBg,
        t,
      )!,
      statusOnHoldBg: Color.lerp(statusOnHoldBg, other.statusOnHoldBg, t)!,
      statusPlanToReadBg: Color.lerp(
        statusPlanToReadBg,
        other.statusPlanToReadBg,
        t,
      )!,
      statusDroppedBg: Color.lerp(statusDroppedBg, other.statusDroppedBg, t)!,
    );
  }
}
