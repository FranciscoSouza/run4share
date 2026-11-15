import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/app/theme/app_text.dart';

/// Light theme for browsing, dark theme for creating.
///
/// The app runs in light mode; the editor, crop and share screens wrap
/// themselves in [AppTheme.dark] whatever the phone's setting.
abstract final class AppTheme {
  static ThemeData get light => _build(
        const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary50,
          onPrimary: AppColors.neutral100,
          primaryContainer: AppColors.primary95,
          onPrimaryContainer: AppColors.primary30,
          secondary: AppColors.neutral0,
          onSecondary: AppColors.neutral100,
          tertiary: AppColors.tertiary60,
          onTertiary: AppColors.neutral100,
          error: AppColors.error40,
          onError: AppColors.neutral100,
          surface: AppColors.neutral99,
          onSurface: AppColors.neutral0,
          onSurfaceVariant: AppColors.neutral40,
          surfaceContainerLowest: AppColors.neutral100,
          surfaceContainerLow: AppColors.neutral100,
          surfaceContainer: AppColors.neutral95,
          surfaceContainerHigh: AppColors.neutral95,
          surfaceContainerHighest: AppColors.neutral90,
          outline: AppColors.neutral80,
          outlineVariant: AppColors.neutral90,
        ),
      );

  static ThemeData get dark => _build(
        const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primary50,
          onPrimary: AppColors.neutral100,
          primaryContainer: AppColors.primary30,
          onPrimaryContainer: AppColors.primary95,
          secondary: AppColors.neutral100,
          onSecondary: AppColors.neutral0,
          tertiary: AppColors.tertiary60,
          onTertiary: AppColors.neutral0,
          error: AppColors.error70,
          onError: AppColors.neutral0,
          surface: AppColors.neutral0,
          onSurface: AppColors.neutral100,
          onSurfaceVariant: AppColors.neutral70,
          surfaceContainerLowest: AppColors.neutral0,
          surfaceContainerLow: AppColors.neutral10,
          surfaceContainer: AppColors.neutral10,
          surfaceContainerHigh: AppColors.neutral20,
          surfaceContainerHighest: AppColors.neutral20,
          outline: AppColors.neutral40,
          outlineVariant: AppColors.neutral20,
        ),
      );

  static ThemeData _build(ColorScheme scheme) {
    final onSurface = scheme.onSurface;
    final textTheme = TextTheme(
      displaySmall: AppText.screenTitle.copyWith(color: onSurface),
      headlineSmall: AppText.section.copyWith(color: onSurface),
      titleMedium: AppText.barTitle.copyWith(color: onSurface),
      bodyLarge: AppText.body.copyWith(color: onSurface),
      bodyMedium: AppText.body.copyWith(color: onSurface),
      bodySmall: AppText.secondary.copyWith(color: scheme.onSurfaceVariant),
      labelLarge: AppText.button.copyWith(color: onSurface),
      labelSmall: AppText.label.copyWith(color: scheme.onSurfaceVariant),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppText.ui,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.barTitle.copyWith(color: onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        hintStyle: AppText.body.copyWith(
          fontSize: 17,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        border: _fieldBorder(scheme.outline),
        enabledBorder: _fieldBorder(scheme.outline),
        focusedBorder: _fieldBorder(scheme.primary, width: 2),
        errorBorder: _fieldBorder(scheme.error),
        focusedErrorBorder: _fieldBorder(scheme.error, width: 2),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppText.secondary.copyWith(
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 26,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.neutral10,
        contentTextStyle: AppText.body.copyWith(
          color: AppColors.neutral100,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color colour, {double width = 1.5}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        borderSide: BorderSide(color: colour, width: width),
      );
}
