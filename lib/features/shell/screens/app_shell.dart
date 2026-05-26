import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storysync/core/permissions/notification_permission_handler.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/features/analytics/engine/analytics_providers_v2.dart';

/// App shell with custom navigation bar and smooth tab transitions.
///
/// Tab switching uses a crossfade + subtle slide-up animation
/// instead of a hard snap.
///
/// Also handles the one-time notification permission prompt. This was
/// moved here from [StorySyncApp] because the shell's [BuildContext]
/// is *inside* the Navigator, which is required for [showModalBottomSheet].
class AppShell extends ConsumerStatefulWidget {
  /// The child widget to display (routed content)
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  /// SharedPreferences key — persists across sessions to avoid re-prompting.
  static const _permissionAskedKey = 'notif_permission_asked';

  /// Instance guard to prevent duplicate dialogs within one session.
  bool _permissionCheckScheduled = false;

  @override
  void initState() {
    super.initState();

    // Defer permission check until the widget tree is fully painted.
    // This guarantees that `context` is valid and has a Navigator ancestor,
    // which is required by the custom BottomSheet inside the handler.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeRequestNotificationPermission();
    });
  }

  /// Request notification permission exactly once, triggered when the user
  /// first achieves a reading streak (currentStreak > 0).
  ///
  /// Uses [SharedPreferences] to persist across sessions, and an instance
  /// guard to prevent duplicate dialogs within one session.
  Future<void> _maybeRequestNotificationPermission() async {
    if (_permissionCheckScheduled) return;
    _permissionCheckScheduled = true;

    if (!mounted) return;

    // Check if we already asked
    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool(_permissionAskedKey) ?? false;
    if (alreadyAsked) return;

    // Check if user has earned a streak (don't bother brand-new users)
    final snapshot = await ref.read(analyticsV2SnapshotProvider.future);
    if (snapshot.currentStreak <= 0) {
      // Reset guard so we re-check on next shell mount
      _permissionCheckScheduled = false;
      return;
    }

    // Mark as asked before showing the prompt
    await prefs.setBool(_permissionAskedKey, true);

    if (mounted) {
      NotificationPermissionHandler.requestIfNeeded(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: _VoidInkNavBar(
        currentIndex: currentIndex,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

/// Custom navigation bar with Void Ink styling
class _VoidInkNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const _VoidInkNavBar({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: AppDimensions.navBarHeight + bottomPadding,
      decoration: BoxDecoration(
        color: colors.inkSurface,
        border: Border(
          top: BorderSide(
            color: colors.inkBorder,
            width: AppDimensions.borderThin,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          children: [
            // Library tab
            Expanded(
              child: _NavItem(
                icon: Icons.collections_bookmark_rounded,
                label: 'Library',
                isSelected: currentIndex == 0,
                onTap: () => onDestinationSelected(0),
              ),
            ),

            // Insights tab
            Expanded(
              child: _NavItem(
                icon: Icons.insights_rounded,
                label: 'Insights',
                isSelected: currentIndex == 1,
                onTap: () => onDestinationSelected(1),
              ),
            ),

            // Discover tab
            Expanded(
              child: _NavItem(
                icon: Icons.search_rounded,
                label: 'Discover',
                isSelected: currentIndex == 2,
                onTap: () => onDestinationSelected(2),
              ),
            ),

            // Settings tab
            Expanded(
              child: _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Settings',
                isSelected: currentIndex == 3,
                onTap: () => onDestinationSelected(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Regular navigation item with animated color transitions
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              key: ValueKey<bool>(isSelected),
              size: 22,
              color: isSelected ? colors.goldSpark : colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.space4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? colors.goldSpark : colors.textSecondary,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
