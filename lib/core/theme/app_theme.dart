import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';

export 'package:storysync/core/theme/app_colors.dart';

/// Void Ink theme - premium theming for StorySync manga tracking
abstract class AppTheme {
  /// Primary dark theme with VoidInkColors extension
  static ThemeData get dark => buildFromColors(VoidInkColors.dark, Brightness.dark);

  /// Light theme variant with VoidInkColors extension
  static ThemeData get light => buildFromColors(VoidInkColors.light, Brightness.light);

  /// Legacy getter for backwards compatibility with existing code
  static ThemeData get darkTheme => dark;

  /// Build a complete [ThemeData] from a [VoidInkColors] palette and
  /// [Brightness]. Used by [dark] and [light] getters, and externally
  /// by the adaptive theme provider for state-reactive palettes.
  static ThemeData buildFromColors(VoidInkColors colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark
        ? ColorScheme.dark(
            surface: colors.inkSurface,
            surfaceContainerHighest: colors.inkPanel,
            primary: colors.goldSpark,
            onPrimary: const Color(0xFF1A0F00),
            secondary: colors.goldLight,
            onSecondary: colors.inkVoid,
            outline: colors.inkBorder,
            outlineVariant: colors.inkMuted,
            onSurface: colors.textPrimary,
            onSurfaceVariant: colors.textSecondary,
            error: colors.statusDropped,
            onError: colors.inkVoid,
          )
        : ColorScheme.light(
            surface: colors.inkSurface,
            surfaceContainerHighest: colors.inkPanel,
            primary: colors.goldSpark,
            onPrimary: Colors.white,
            secondary: colors.goldLight,
            onSecondary: colors.textPrimary,
            outline: colors.inkBorder,
            outlineVariant: colors.inkMuted,
            onSurface: colors.textPrimary,
            onSurfaceVariant: colors.textSecondary,
            error: colors.statusDropped,
            onError: Colors.white,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.inkVoid,
      extensions: [colors],
      colorScheme: colorScheme,
      fontFamily: 'DMSans',
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: colors.textPrimary,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: colors.textPrimary,
        ),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: colors.textPrimary,
        ),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(
          color: colors.textPrimary,
        ),
        titleLarge: AppTextStyles.titleLarge.copyWith(
          color: colors.textPrimary,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: colors.textPrimary,
        ),
        titleSmall: AppTextStyles.titleSmall.copyWith(
          color: colors.textPrimary,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: colors.textSecondary,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: colors.textSecondary,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: colors.textSecondary,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: colors.textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.inkVoid,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: colors.textPrimary,
        ),
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.inkSurface,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        height: AppDimensions.navBarHeight,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppTextStyles.labelSmall.copyWith(color: colors.goldSpark)
              : AppTextStyles.labelSmall.copyWith(color: colors.textSecondary),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.goldSpark
                : colors.textSecondary,
            size: 22,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.inkSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          side: BorderSide(
            color: colors.inkBorder,
            width: AppDimensions.borderThin,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inkPanel,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textHint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          borderSide: BorderSide(
            color: colors.inkBorder,
            width: AppDimensions.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          borderSide: BorderSide(
            color: colors.inkBorder,
            width: AppDimensions.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          borderSide: BorderSide(color: colors.goldSpark, width: 1.0),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.inkBorder,
        thickness: AppDimensions.borderThin,
        space: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.inkPanel,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusMD),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.inkPanel,
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: colors.textPrimary,
        ),
        side: BorderSide(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: colors.inkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        titleTextStyle: AppTextStyles.titleSmall.copyWith(
          color: colors.textPrimary,
        ),
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(
          color: colors.textSecondary,
        ),
        leadingAndTrailingTextStyle: AppTextStyles.bodySmall.copyWith(
          color: colors.textSecondary,
        ),
        iconColor: colors.textSecondary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.inkPanel,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.inkPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: colors.textPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
