import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mtrack/core/theme/app_colors.dart';
import 'package:mtrack/core/theme/app_dimensions.dart';
import 'package:mtrack/core/theme/app_text_styles.dart';

/// Void Ink theme - premium dark theme for manga tracking
abstract class AppTheme {
  /// Primary dark theme
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.inkVoid,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.inkSurface,
        surfaceContainerHighest: AppColors.inkPanel,
        primary: AppColors.goldSpark,
        onPrimary: Color(0xFF1A0F00),
        secondary: AppColors.goldLight,
        onSecondary: AppColors.inkVoid,
        outline: AppColors.inkBorder,
        outlineVariant: AppColors.inkMuted,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        error: AppColors.statusDropped,
        onError: AppColors.inkVoid,
      ),
      fontFamily: 'DMSans',
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.inkVoid,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: AppTextStyles.headlineMedium,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.inkSurface,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        height: AppDimensions.navBarHeight,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppTextStyles.labelSmall.copyWith(color: AppColors.goldSpark)
              : AppTextStyles.labelSmall,
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.goldSpark
                : AppColors.textSecondary,
            size: 22,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.inkSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          side: const BorderSide(
            color: AppColors.inkBorder,
            width: AppDimensions.borderThin,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inkPanel,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          borderSide: const BorderSide(
            color: AppColors.inkBorder,
            width: AppDimensions.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          borderSide: const BorderSide(
            color: AppColors.inkBorder,
            width: AppDimensions.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          borderSide: const BorderSide(color: AppColors.goldSpark, width: 1.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.inkBorder,
        thickness: AppDimensions.borderThin,
        space: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.inkPanel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusMD),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.inkPanel,
        labelStyle: AppTextStyles.labelSmall,
        side: const BorderSide(
          color: AppColors.inkBorder,
          width: AppDimensions.borderThin,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: AppColors.inkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        titleTextStyle: AppTextStyles.titleSmall,
        subtitleTextStyle: AppTextStyles.bodySmall,
        leadingAndTrailingTextStyle: AppTextStyles.bodySmall,
        iconColor: AppColors.textSecondary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.inkPanel,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Light theme variant
  static ThemeData get light {
    return dark.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAF8),
      colorScheme: dark.colorScheme.copyWith(
        brightness: Brightness.light,
        surface: Colors.white,
        surfaceContainerHighest: const Color(0xFFF4F2EE),
        onSurface: const Color(0xFF18181A),
        onSurfaceVariant: const Color(0xFF5A5A60),
        outline: const Color(0xFFDDDDD8),
        outlineVariant: const Color(0xFFECECE8),
      ),
    );
  }

  /// Legacy getter for backwards compatibility with existing code
  static ThemeData get darkTheme => dark;
}
