import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/core/utils/haptic_util.dart';

import 'package:storysync/features/library/presentation/controllers/reading_empty_state_provider.dart';

/// Dynamic empty-state widget for the Reading tab.
///
/// Renders one of two scenarios based on [readingEmptyScenarioProvider]:
/// - **Absolute Beginner**: Shows a "Discover New Titles" CTA.
/// - **Has Backlog**: Shows contextual buttons for Plan to Read / On Hold.
///
/// For non-Reading tabs, use the standard [_SimpleEmptyState] instead.
class ReadingEmptyState extends ConsumerStatefulWidget {
  final VoidInkColors colors;

  const ReadingEmptyState({super.key, required this.colors});

  @override
  ConsumerState<ReadingEmptyState> createState() => _ReadingEmptyStateState();
}

class _ReadingEmptyStateState extends ConsumerState<ReadingEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scenario = ref.watch(readingEmptyScenarioProvider);
    final colors = widget.colors;

    // While loading, show nothing (shimmer is handled by the parent).
    if (scenario == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space32,
            ),
            child: switch (scenario) {
              AbsoluteBeginner() => _AbsoluteBeginnerContent(colors: colors),
              HasBacklog(:final hasPlanToRead, :final hasOnHold) =>
                _BacklogContent(
                  colors: colors,
                  hasPlanToRead: hasPlanToRead,
                  hasOnHold: hasOnHold,
                ),
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scenario A — Absolute Beginner
// ─────────────────────────────────────────────────────────────────────────────

class _AbsoluteBeginnerContent extends StatelessWidget {
  final VoidInkColors colors;

  const _AbsoluteBeginnerContent({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Decorative icon with glow ──
        _GlowIcon(
          icon: Icons.auto_stories_rounded,
          color: colors.goldSpark,
          glowColor: colors.goldDim,
        ),
        const SizedBox(height: AppDimensions.space24),

        // ── Headline ──
        Text(
          'Your story begins here',
          style: AppTextStyles.headlineSmall.copyWith(
            color: colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space8),

        // ── Subtitle ──
        Text(
          'Search thousands of titles and start building\nyour personal manga library',
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space32),

        // ── CTA Button ──
        _PremiumButton(
          label: 'Discover New Titles',
          icon: Icons.explore_rounded,
          accentColor: colors.goldSpark,
          surfaceColor: colors.inkSurface,
          borderColor: colors.inkBorder,
          textColor: colors.goldSpark,
          onTap: () {
            StorySyncHaptics.mediumTap();
            // Navigate to Discover tab (index 2 in StatefulShellRoute)
            _navigateToShellBranch(context, 2);
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scenario B — Has Backlog
// ─────────────────────────────────────────────────────────────────────────────

class _BacklogContent extends StatelessWidget {
  final VoidInkColors colors;
  final bool hasPlanToRead;
  final bool hasOnHold;

  const _BacklogContent({
    required this.colors,
    required this.hasPlanToRead,
    required this.hasOnHold,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Decorative icon ──
        _GlowIcon(
          icon: Icons.bookmark_border_rounded,
          color: colors.textSecondary,
          glowColor: colors.inkMuted,
        ),
        const SizedBox(height: AppDimensions.space24),

        // ── Headline ──
        Text(
          'Nothing in progress',
          style: AppTextStyles.headlineSmall.copyWith(
            color: colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space8),

        // ── Subtitle ──
        Text(
          'Pick up where you left off or start\nsomething from your backlog',
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space32),

        // ── Contextual buttons ──
        if (hasPlanToRead)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.space12),
            child: _PremiumButton(
              label: 'View Plan to Read',
              icon: Icons.format_list_bulleted_rounded,
              accentColor: colors.statusPlanToRead,
              surfaceColor: colors.inkSurface,
              borderColor: colors.inkBorder,
              textColor: colors.statusPlanToRead,
              onTap: () {
                StorySyncHaptics.lightTap();
                // Navigate to Library > Plan to Read tab (index 3 in TabBar)
                _navigateToLibraryTab(context, 3);
              },
            ),
          ),
        if (hasOnHold)
          _PremiumButton(
            label: 'View On Hold',
            icon: Icons.pause_circle_outline_rounded,
            accentColor: colors.statusOnHold,
            surfaceColor: colors.inkSurface,
            borderColor: colors.inkBorder,
            textColor: colors.statusOnHold,
            onTap: () {
              StorySyncHaptics.lightTap();
              // Navigate to Library > On Hold tab (index 2 in TabBar)
              _navigateToLibraryTab(context, 2);
            },
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Components
// ─────────────────────────────────────────────────────────────────────────────

/// A premium button with smoked-glass effect, subtle border, and press animation.
class _PremiumButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _PremiumButton({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressController.reverse(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space24,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.18),
                  width: AppDimensions.borderThin,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 18, color: widget.textColor),
                  const SizedBox(width: AppDimensions.space8),
                  Text(
                    widget.label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: widget.textColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Decorative icon with a soft radial glow behind it.
class _GlowIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color glowColor;

  const _GlowIcon({
    required this.icon,
    required this.color,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow layer
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glowColor.withValues(alpha: 0.18),
                  glowColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // Icon
          Icon(icon, size: 40, color: color),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Navigates to a shell branch (bottom nav tab) by index.
///
/// Uses [StatefulNavigationShell.goBranch] via GoRouter path to ensure
/// the shell's state is preserved correctly.
void _navigateToShellBranch(BuildContext context, int branchIndex) {
  // Map branch indices to their root paths
  const branchPaths = ['/library', '/insights', '/discover', '/settings'];
  if (branchIndex >= 0 && branchIndex < branchPaths.length) {
    context.go(branchPaths[branchIndex]);
  }
}

/// Navigates to a specific tab within the Library screen's TabBar.
///
/// This dispatches a notification up the widget tree that the
/// LibraryScreen's TabController can listen to.
void _navigateToLibraryTab(BuildContext context, int tabIndex) {
  LibraryTabNotification(tabIndex).dispatch(context);
}

/// Notification dispatched to request a Library tab switch.
///
/// Consumed by [LibraryScreen]'s [NotificationListener] to
/// programmatically animate the TabController.
class LibraryTabNotification extends Notification {
  final int tabIndex;
  const LibraryTabNotification(this.tabIndex);
}
