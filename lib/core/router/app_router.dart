import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storysync/features/auth/screens/welcome_screen.dart';
import 'package:storysync/features/details/screens/details_screen.dart';
import 'package:storysync/features/discover/screens/discover_screen.dart';
import 'package:storysync/features/library/screens/library_screen.dart';
import 'package:storysync/features/settings/screens/settings_screen.dart';
import 'package:storysync/features/shell/screens/app_shell.dart';

/// App router configuration with Void Ink design system
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(bool isFirstRun) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: isFirstRun ? '/welcome' : '/library',
      routes: [
        // Welcome route (outside shell)
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),

      // Main app shell with tab navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Library branch
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(),
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),

          // Discover branch
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(),
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoverScreen(),
              ),
            ],
          ),

          // Settings branch
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(),
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Details route (outside shell, full screen) with custom transition
      GoRoute(
        path: '/details/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final mangaId = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: DetailsScreen(mangaId: mangaId),
            transitionDuration: const Duration(milliseconds: 350),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  // Combine fade and slight slide up for a premium feel
                  final fadeAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  );
                  final slideAnimation =
                      Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: child,
                    ),
                  );
                },
          );
        },
      ),
    ],
    );
  }
}
