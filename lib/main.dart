import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:storysync/core/providers/shared_prefs_provider.dart';
import 'package:storysync/core/providers/theme_provider.dart';
import 'package:storysync/core/router/app_router.dart';
import 'package:storysync/core/theme/app_theme.dart';
import 'package:storysync/core/native/widget_service.dart';
import 'package:storysync/core/notifications/notification_service.dart';
import 'package:storysync/core/notifications/streak_worker.dart';
// NOTE: Notification permission logic moved to AppShell (inside Navigator)
// to ensure valid BuildContext for showModalBottomSheet.
import 'package:storysync/features/analytics/engine/analytics_providers_v2.dart';
import 'package:storysync/features/analytics/services/analytics_cache_service.dart';
import 'package:storysync/features/analytics/ui/adaptive_theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final widgetService = WidgetService();
  await widgetService.initialize();

  final sharedPreferences = await SharedPreferences.getInstance();

  // Unlock high-refresh-rate displays (90Hz/120Hz)
  // Android often locks Flutter apps to 60Hz by default.
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (_) {
    // Graceful fallback for non-Android or unsupported devices
  }

  // Initialize local notifications for streak reminders
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Register background streak check worker
  await registerStreakWorker();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const StorySyncApp(),
    ),
  );
}

/// Root application widget.
///
/// Phase 14 additions:
/// - Watches [adaptiveColorsProvider] for state-reactive theme palettes.
/// - Listens to [analyticsV2SnapshotProvider] to keep the background
///   worker cache in sync (via [AnalyticsCacheService]).
/// - Triggers one-time notification permission prompt when the user
///   first achieves a streak (context-aware, not on boot).
class StorySyncApp extends ConsumerStatefulWidget {
  const StorySyncApp({super.key});

  @override
  ConsumerState<StorySyncApp> createState() => _StorySyncAppState();
}

class _StorySyncAppState extends ConsumerState<StorySyncApp> {

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isFirstRun = ref.watch(isFirstRunProvider);

    // Phase 14: Adaptive theme — shifts palette based on user state
    final adaptiveColors = ref.watch(adaptiveColorsProvider);

    // Phase 14: Cache analytics snapshot for the background worker.
    // Notification permission prompt has been moved to AppShell where
    // the BuildContext is inside the Navigator hierarchy.
    ref.listen(analyticsV2SnapshotProvider, (_, next) {
      next.whenData((snapshot) {
        AnalyticsCacheService.instance.saveSnapshot(snapshot);
      });
    });

    return MaterialApp.router(
      title: 'StorySync',
      debugShowCheckedModeBanner: false,

      // Void Ink theme with adaptive state-reactive palettes
      theme: AppTheme.buildFromColors(adaptiveColors.light, Brightness.light),
      darkTheme: AppTheme.buildFromColors(adaptiveColors.dark, Brightness.dark),
      themeMode: themeMode,

      // Router configuration
      routerConfig: AppRouter.createRouter(isFirstRun),

      // Dynamically set system UI overlay style based on resolved brightness
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final colors = Theme.of(context).extension<VoidInkColors>()!;
        final overlayStyle = brightness == Brightness.dark
            ? SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarColor: colors.inkSurface,
                systemNavigationBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: colors.inkSurface,
                systemNavigationBarIconBrightness: Brightness.dark,
              );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: child!,
        );
      },
    );
  }

}
