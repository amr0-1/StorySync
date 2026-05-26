import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/features/analytics/engine/analytics_providers_v2.dart';

// ════════════════════════════════════════════════════════════════════
// Adaptive Theme Provider
// ════════════════════════════════════════════════════════════════════
//
// Watches the user's analytic state (Hot / Fatigued / Standard) and
// returns the matching VoidInkColors variant. Changes are extremely
// subtle (5–10% HSL saturation shift) to preserve the Void Ink identity.
//
// The provider uses `.select()` to only trigger rebuilds when the
// adaptive state *category* changes, NOT on every analytics tick.
// ════════════════════════════════════════════════════════════════════

/// Internal state — only 3 possible values = very low rebuild frequency.
enum AdaptiveState { standard, vibrant, muted }

/// Derives the [AdaptiveState] from the V2 analytics user state.
///
/// Uses `.select()` so it only fires when the boolean thresholds
/// (`isHot` / `isFatigued`) cross a boundary, not on every
/// chapter increment.
final adaptiveStateProvider = Provider<AdaptiveState>((ref) {
  return ref.watch(
    userStateProvider.select((asyncValue) {
      return asyncValue.maybeWhen(
        data: (state) {
          if (state.isHot) return AdaptiveState.vibrant;
          if (state.isFatigued) return AdaptiveState.muted;
          return AdaptiveState.standard;
        },
        orElse: () => AdaptiveState.standard,
      );
    }),
  );
});

/// Provides the correct [VoidInkColors] variant for both brightness modes.
///
/// Consumed by `main.dart` to build the adaptive [ThemeData]:
/// ```dart
/// final ac = ref.watch(adaptiveColorsProvider);
/// theme: AppTheme.buildFromColors(ac.light, Brightness.light),
/// darkTheme: AppTheme.buildFromColors(ac.dark, Brightness.dark),
/// ```
final adaptiveColorsProvider =
    Provider<({VoidInkColors dark, VoidInkColors light})>((ref) {
  final state = ref.watch(adaptiveStateProvider);

  return switch (state) {
    AdaptiveState.vibrant => (
        dark: VoidInkColors.dark.vibrant,
        light: VoidInkColors.light.vibrant,
      ),
    AdaptiveState.muted => (
        dark: VoidInkColors.dark.muted,
        light: VoidInkColors.light.muted,
      ),
    AdaptiveState.standard => (
        dark: VoidInkColors.dark,
        light: VoidInkColors.light,
      ),
  };
});
