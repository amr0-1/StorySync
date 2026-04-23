import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storysync/core/providers/shared_prefs_provider.dart';
import 'package:storysync/core/providers/theme_provider.dart';
import 'package:storysync/core/router/app_router.dart';
import 'package:storysync/core/theme/app_theme.dart';
import 'package:storysync/core/native/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final widgetService = WidgetService();
  await widgetService.initialize();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const StorySyncApp(),
    ),
  );
}

class StorySyncApp extends ConsumerWidget {
  const StorySyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isFirstRun = ref.watch(isFirstRunProvider);

    return MaterialApp.router(
      title: 'StorySync',
      debugShowCheckedModeBanner: false,

      // Void Ink theme with dynamic theme mode
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
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
