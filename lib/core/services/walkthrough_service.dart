import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

/// Builds and manages the interactive "Void Ink" walkthrough overlay.
///
/// All targets are confined to the [LibraryScreen] to guarantee
/// structural safety — no cross-tab GlobalKey dependencies.
///
/// Design constraints:
/// - `colorShadow: Colors.black` with `opacityShadow: 0.85`
/// - Stark white headings (`Colors.white`) with grey subtitles (`Colors.white70`)
class WalkthroughService {
  WalkthroughService._();

  /// Constructs the ordered list of walkthrough focus targets.
  ///
  /// Both keys must be attached to leaf-node widgets on the Library tab
  /// (the initial tab), guaranteeing they are mounted at show-time.
  static List<TargetFocus> buildTargets({
    required GlobalKey addTitleKey,
    required GlobalKey quickIncrementKey,
    required GlobalKey analyticsHeatmapKey,
    required GlobalKey backupSettingsKey,
  }) {
    return [
      // ── Target 1: Add / Discover ──────────────────────────────
      TargetFocus(
        identify: 'addTitle',
        keyTarget: addTitleKey,
        alignSkip: Alignment.bottomRight,
        enableOverlayTab: true,
        color: Colors.black,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTargetContent(
                title: 'Build Your Library',
                subtitle:
                    'Search and add your active Manga and Manhwa here.',
              );
            },
          ),
        ],
      ),

      // ── Target 2: Quick Increment / Layout Toggle ─────────────
      TargetFocus(
        identify: 'quickIncrement',
        keyTarget: quickIncrementKey,
        alignSkip: Alignment.bottomRight,
        enableOverlayTab: true,
        color: Colors.black,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTargetContent(
                title: 'Zero-Latency Tracking',
                subtitle:
                    'Instantly update your progress directly from your library.',
              );
            },
          ),
        ],
      ),

      // ── Target 3: Analytics / Insights ─────────────
      TargetFocus(
        identify: 'analyticsHeatmap',
        keyTarget: analyticsHeatmapKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        color: Colors.black,
        shape: ShapeLightFocus.Circle,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTargetContent(
                title: 'Reading Insights',
                subtitle:
                    'Visualize your reading habits and track your streaks over time.',
              );
            },
          ),
        ],
      ),

      // ── Target 4: Backup / Settings ─────────────
      TargetFocus(
        identify: 'backupSettings',
        keyTarget: backupSettingsKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        color: Colors.black,
        shape: ShapeLightFocus.Circle,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTargetContent(
                title: 'Data Safety',
                subtitle:
                    'Export your library locally, or customize the app\'s appearance.',
              );
            },
          ),
        ],
      ),
    ];
  }

  /// Creates a [TutorialCoachMark] configured with Void Ink aesthetics.
  ///
  /// [onFinish] and [onSkip] are called when the tutorial ends (naturally
  /// or via skip). Both should persist `hasSeenWalkthrough = true`.
  static TutorialCoachMark create({
    required List<TargetFocus> targets,
    required VoidCallback onFinish,
    required VoidCallback onSkip,
  }) {
    return TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      textSkip: 'Skip Demo',
      textStyleSkip: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 400),
      unFocusAnimationDuration: const Duration(milliseconds: 300),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      onFinish: onFinish,
      onSkip: () {
        onSkip();
        return true; // Return true to allow skip
      },
    );
  }

  // ── Private helpers ─────────────────────────────────────────────

  static Widget _buildTargetContent({
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
