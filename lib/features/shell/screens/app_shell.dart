import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';

/// App shell with custom navigation bar and floating discover FAB
class AppShell extends StatelessWidget {
  /// The child widget to display (routed content)
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _VoidInkNavBar(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

/// Custom navigation bar with Void Ink styling
/// Uses a Stack to properly position the floating FAB without overflow
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

    return SizedBox(
      // Extra height to accommodate the FAB overflow above the bar
      height: AppDimensions.navBarHeight + bottomPadding + 12,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Layer 1: The actual navigation bar surface
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
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

                    // Empty space for the FAB
                    const Expanded(child: SizedBox.shrink()),

                    // Settings tab
                    Expanded(
                      child: _NavItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Settings',
                        isSelected: currentIndex == 2,
                        onTap: () => onDestinationSelected(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Layer 2: Floating FAB positioned to overlap the top edge
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: _NavFabItem(
              isSelected: currentIndex == 1,
              onTap: () => onDestinationSelected(1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Regular navigation item
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
          Icon(
            icon,
            size: 22,
            color: isSelected ? colors.goldSpark : colors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? colors.goldSpark : colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating FAB-style discover button in the center
class _NavFabItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _NavFabItem({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Floating FAB
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: AppDimensions.navFabSize,
            height: AppDimensions.navFabSize,
            decoration: BoxDecoration(
              color: colors.goldSpark,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.goldSpark.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF1A0F00),
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Label
        Text(
          'Discover',
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? colors.goldSpark : colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
