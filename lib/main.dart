import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storysync/core/providers/theme_provider.dart';
import 'package:storysync/core/router/app_router.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: StorySyncApp()));
}

class StorySyncApp extends ConsumerWidget {
  const StorySyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'StorySync',
      debugShowCheckedModeBanner: false,

      // Void Ink theme with dynamic theme mode
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Router configuration
      routerConfig: AppRouter.router,

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
