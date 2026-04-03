import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtrack/features/auth/screens/login_screen.dart';
import 'package:mtrack/features/details/screens/details_screen.dart';
import 'package:mtrack/features/discover/screens/discover_screen.dart';
import 'package:mtrack/features/library/screens/library_screen.dart';
import 'package:mtrack/features/settings/screens/settings_screen.dart';
import 'package:mtrack/features/shell/screens/app_shell.dart';

/// App router configuration with Void Ink design system
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      // Login route (outside shell)
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

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

      // Details route (outside shell, full screen)
      GoRoute(
        path: '/details/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final mangaId = state.pathParameters['id'] ?? '';
          return DetailsScreen(mangaId: mangaId);
        },
      ),
    ],
  );
}
