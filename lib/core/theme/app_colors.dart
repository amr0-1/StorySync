import 'package:flutter/material.dart';
import 'package:mtrack/core/models/reading_status.dart';

/// Void Ink color palette - premium dark theme with gold accents
abstract class AppColors {
  // ── Backgrounds ────────────────────────────────────────────
  static const Color inkVoid = Color(0xFF08080A); // Scaffold bg
  static const Color inkSurface = Color(0xFF111115); // Card, nav bar bg
  static const Color inkPanel = Color(0xFF1C1C22); // Elevated panels, steppers
  static const Color inkBorder = Color(0xFF28282F); // Default border color
  static const Color inkMuted = Color(0xFF3D3D46); // Hover/pressed state bg

  // ── Gold Accent ─────────────────────────────────────────────
  static const Color goldSpark = Color(
    0xFFE8A43F,
  ); // Primary accent, FAB, +1 btn
  static const Color goldLight = Color(
    0xFFF5C878,
  ); // Highlighted text on dark bg
  static const Color goldDim = Color(
    0xFF9A6B1F,
  ); // Pressed state of gold elements

  // ── Text ────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF2EEE8); // Main text (warm cream)
  static const Color textSecondary = Color(
    0xFF9B978F,
  ); // Muted labels, subtitles
  static const Color textHint = Color(0xFF58565A); // Placeholder, hint text

  // ── Status Colors ───────────────────────────────────────────
  static const Color statusReading = Color(0xFF1FC8A0); // Teal
  static const Color statusCompleted = Color(0xFF52C27A); // Green
  static const Color statusOnHold = Color(
    0xFFE8A43F,
  ); // Amber (same as goldSpark)
  static const Color statusPlanToRead = Color(0xFF9178E8); // Purple
  static const Color statusDropped = Color(0xFFE85A5A); // Red

  // ── Status Background Tints (12% opacity) ───────────────────
  static const Color statusReadingBg = Color(0x1F1FC8A0);
  static const Color statusCompletedBg = Color(0x1F52C27A);
  static const Color statusOnHoldBg = Color(0x1FE8A43F);
  static const Color statusPlanToReadBg = Color(0x1F9178E8);
  static const Color statusDroppedBg = Color(0x1FE85A5A);

  // ── Utility ─────────────────────────────────────────────────
  static const Color white = Color(0xFFF2EEE8);
  static const Color transparent = Colors.transparent;

  /// Returns the foreground color for a given reading status
  static Color forStatus(ReadingStatus status) => switch (status) {
    ReadingStatus.reading => statusReading,
    ReadingStatus.completed => statusCompleted,
    ReadingStatus.onHold => statusOnHold,
    ReadingStatus.planToRead => statusPlanToRead,
    ReadingStatus.dropped => statusDropped,
  };

  /// Returns the background tint for a given reading status
  static Color bgForStatus(ReadingStatus status) => switch (status) {
    ReadingStatus.reading => statusReadingBg,
    ReadingStatus.completed => statusCompletedBg,
    ReadingStatus.onHold => statusOnHoldBg,
    ReadingStatus.planToRead => statusPlanToReadBg,
    ReadingStatus.dropped => statusDroppedBg,
  };
}
