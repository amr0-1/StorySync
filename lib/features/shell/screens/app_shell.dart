import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';

/// App shell with custom navigation bar
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
