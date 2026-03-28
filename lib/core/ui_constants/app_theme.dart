import 'package:flutter/material.dart';

import 'app_radii.dart';
import 'app_spacing.dart';

/// Material 3 themes for the app. Use [lightTheme] / [darkTheme] from [GetMaterialApp].
abstract final class AppTheme {
  static ThemeData lightTheme({Color? seedColor}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor ?? const Color(0xFF6750A4),
      brightness: Brightness.light,
    );
    return _base(scheme);
  }

  static ThemeData darkTheme({Color? seedColor}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor ?? const Color(0xFFD0BCFF),
      brightness: Brightness.dark,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
        clipBehavior: Clip.antiAlias,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: AppRadii.sm),
        filled: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 4,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 4,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
    );
  }
}
