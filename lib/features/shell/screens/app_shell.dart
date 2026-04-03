import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtrack/core/theme/app_colors.dart';
import 'package:mtrack/core/theme/app_dimensions.dart';
import 'package:mtrack/core/theme/app_text_styles.dart';

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
class _VoidInkNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const _VoidInkNavBar({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.inkSurface,
        border: Border(
          top: BorderSide(
            color: AppColors.inkBorder,
            width: AppDimensions.borderThin,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimensions.navBarHeight,
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

              // Discover tab (FAB style)
              Expanded(
                child: _NavFabItem(
                  isSelected: currentIndex == 1,
                  onTap: () => onDestinationSelected(1),
                ),
              ),

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
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? AppColors.goldSpark : AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.goldSpark : AppColors.textSecondary,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Floating FAB
        Transform.translate(
          offset: const Offset(0, -12),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: AppDimensions.navFabSize,
              height: AppDimensions.navFabSize,
              decoration: BoxDecoration(
                color: AppColors.goldSpark,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldSpark.withValues(alpha: 0.3),
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
        ),
        // Label
        Transform.translate(
          offset: const Offset(0, -8),
          child: Text(
            'Discover',
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.goldSpark : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
