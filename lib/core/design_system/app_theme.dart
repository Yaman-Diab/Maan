// -------------------------
// App Theme
// -------------------------

import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_semantic_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(
    brightness: Brightness.light,
    scheme: _lightScheme,
    semanticColors: AppSemanticColors.light,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    scheme: _darkScheme,
    semanticColors: AppSemanticColors.dark,
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

  /// النسخة الداكنة.
  ///
  /// لون الهوية `teal600` غامق زيادة على خلفية داكنة (تباين ضعيف)، فبنفتحه
  /// للـ `teal400`. نفس الشي للأحمر والكهرماني — الهوية محفوظة والقراءة
  /// بتضل مريحة.
  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.teal400,
    onPrimary: AppPalette.darkCanvas,
    primaryContainer: Color(0xFF14332E),
    onPrimaryContainer: AppPalette.teal400,
    secondary: AppPalette.amber400,
    onSecondary: AppPalette.darkCanvas,
    secondaryContainer: Color(0xFF2A2213),
    onSecondaryContainer: AppPalette.amber400,
    tertiary: AppPalette.orange500,
    onTertiary: AppPalette.darkCanvas,
    error: AppPalette.red400,
    onError: AppPalette.darkCanvas,
    errorContainer: Color(0xFF3A1B1B),
    onErrorContainer: AppPalette.red400,
    surface: AppPalette.darkSurface,
    onSurface: AppPalette.darkTextPrimary,
    surfaceContainerLowest: AppPalette.darkCanvas,
    surfaceContainerLow: AppPalette.darkSurface,
    surfaceContainer: AppPalette.darkSurfaceElevated,
    onSurfaceVariant: AppPalette.darkTextSecondary,
    outline: AppPalette.darkBorder,
    outlineVariant: AppPalette.darkBorder,
    inverseSurface: AppPalette.white,
    onInverseSurface: AppPalette.ink900,
    shadow: Color(0x66000000),
    scrim: Color(0x99000000),
  );

  // -------------------------
  // Builder
  // -------------------------

  /// ⚠️ لازم تتنادى من جوّا `ScreenUtilInit` — أنماط النصوص بتستخدم `.sp`،
  /// فلو انبنى الثيم برّا، بتنحسب القياسات على مقاس غلط.
  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required AppSemanticColors semanticColors,
  }) {
    final textStyles = AppTextStyles.from(
      colors: semanticColors,
      scheme: scheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Poppins',
      textTheme: textStyles.toTextTheme(),

      // التوكنات اللي ما إلها مقابل بـ ColorScheme.
      extensions: <ThemeExtension<dynamic>>[semanticColors, textStyles],

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
