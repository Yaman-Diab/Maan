// -------------------------
// App Theme
// -------------------------

import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_semantic_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(
    brightness: Brightness.light,
    scheme: _lightScheme,
    semanticColors: AppSemanticColors.light,
  );

  // -------------------------
  // Color Schemes
  // -------------------------

  /// `ColorScheme` كاملة لا أربع ألوان: Material 3 بيشتق منها ألوان
  /// عشرات الـ widgets الجاهزة (SnackBar، Dialog، Chip، NavigationBar).
  /// تركها ناقصة معناه إن الباقي بياخد قيم افتراضية بتضرب الهوية البصرية.
  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.teal600,
    onPrimary: AppPalette.white,
    primaryContainer: AppPalette.amber50,
    onPrimaryContainer: AppPalette.teal600,
    secondary: AppPalette.amber700,
    onSecondary: AppPalette.white,
    secondaryContainer: AppPalette.amber50,
    onSecondaryContainer: AppPalette.amber700,
    tertiary: AppPalette.orange500,
    onTertiary: AppPalette.white,
    error: AppPalette.red600,
    onError: AppPalette.white,
    errorContainer: Color(0xFFFCE8E8),
    onErrorContainer: AppPalette.red600,
    surface: AppPalette.white,
    onSurface: AppPalette.ink900,
    surfaceContainerLowest: AppPalette.white,
    surfaceContainerLow: AppPalette.canvas,
    surfaceContainer: AppPalette.canvas,
    onSurfaceVariant: AppPalette.slate500,
    outline: AppPalette.grey200,
    outlineVariant: AppPalette.grey300,
    inverseSurface: AppPalette.ink900,
    onInverseSurface: AppPalette.white,
    shadow: Color(0x1A000000),
    scrim: Color(0x66000000),
  );

  // -------------------------
  // Builder
  // -------------------------

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required AppSemanticColors semanticColors,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Poppins',

      // التوكنات اللي ما إلها مقابل بـ ColorScheme.
      extensions: <ThemeExtension<dynamic>>[semanticColors],

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: semanticColors.fieldBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 14,
        ),
        border: _fieldBorder(scheme.outline),
        enabledBorder: _fieldBorder(scheme.outline),
        disabledBorder: _fieldBorder(scheme.outline),
        focusedBorder: _fieldBorder(scheme.primary),
        errorBorder: _fieldBorder(scheme.error),
        focusedErrorBorder: _fieldBorder(scheme.error),
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: color),
    );
  }
}
