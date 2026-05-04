import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storysync/features/auth/screens/welcome_screen.dart';
import 'package:storysync/features/details/screens/details_screen.dart';
import 'package:storysync/features/discover/screens/discover_screen.dart';
import 'package:storysync/features/insights/screens/insights_screen.dart';
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
        // Welcome route (outside shell) with fade-in transition
        GoRoute(
          path: '/welcome',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const WelcomeScreen(),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: _voidInkTransition,
          ),
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
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const LibraryScreen(),
                    transitionDuration: const Duration(milliseconds: 300),
                    reverseTransitionDuration: const Duration(
                      milliseconds: 250,
                    ),
                    transitionsBuilder: _voidInkTransition,
                  ),
                ),
              ],
            ),

            // Insights branch
            StatefulShellBranch(
              navigatorKey: GlobalKey<NavigatorState>(),
              routes: [
                GoRoute(
                  path: '/insights',
                  pageBuilder: (context, state) {
                    final dateStr = state.uri.queryParameters['date'];
                    DateTime? initialDate;
                    if (dateStr != null) {
                      initialDate = DateTime.tryParse(dateStr);
                    }
                    return CustomTransitionPage(
                      key: state.pageKey,
                      child: InsightsScreen(initialDate: initialDate),
                      transitionDuration: const Duration(milliseconds: 300),
                      reverseTransitionDuration: const Duration(
                        milliseconds: 250,
                      ),
                      transitionsBuilder: _voidInkTransition,
                    );
                  },
                ),
              ],
            ),

            // Discover branch
            StatefulShellBranch(
              navigatorKey: GlobalKey<NavigatorState>(),
              routes: [
                GoRoute(
                  path: '/discover',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const DiscoverScreen(),
                    transitionDuration: const Duration(milliseconds: 300),
                    reverseTransitionDuration: const Duration(
                      milliseconds: 250,
                    ),
                    transitionsBuilder: _voidInkTransition,
                  ),
                ),
              ],
            ),

            // Settings branch
            StatefulShellBranch(
              navigatorKey: GlobalKey<NavigatorState>(),
              routes: [
                GoRoute(
                  path: '/settings',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const SettingsScreen(),
                    transitionDuration: const Duration(milliseconds: 300),
                    reverseTransitionDuration: const Duration(
                      milliseconds: 250,
                    ),
                    transitionsBuilder: _voidInkTransition,
                  ),
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
              transitionsBuilder: _voidInkTransition,
            );
          },
        ),
      ],
    );
  }

  /// Shared "Void Ink" page transition: combined fade + subtle slide-up.
  ///
  /// Used across all routes for a consistent, premium feel.
  static Widget _voidInkTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    );
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }
}
