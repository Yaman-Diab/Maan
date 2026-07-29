// -------------------------
// App Semantic Colors
// -------------------------

import 'package:flutter/material.dart';

import 'app_palette.dart';

/// التوكنات اللونية اللي ما إلها مقابل بـ`ColorScheme` تبع Material.
///
/// كل توكن مسمّى **حسب دوره** لا حسب شكله: `textPrimary` مش `black`.
/// هيك لما يجي الثيم الداكن بتتبدّل القيمة بلا ما يتغير اسم ولا موقع
/// استدعاء واحد — وهاد بالضبط اللي بيخلّي الـ dark mode تعبئة قيم
/// مش إعادة كتابة widgets.
///
/// الاستخدام: `context.colors.textPrimary` — راجع `AppThemeContext`.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  // النصوص
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  // الحدود والفواصل
  final Color border;
  final Color divider;

  // الأسطح
  final Color pageBackground;
  final Color fieldBackground;
  final Color fieldDisabledBackground;

  // الحالات
  final Color success;
  final Color warning;

  // صندوق التنبيه (شروط الاستخدام)
  final Color noticeBackground;
  final Color noticeForeground;

  // صندوق المساعدة (معلومات)
  final Color infoBackground;
  final Color infoForeground;

  const AppSemanticColors({
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.border,
    required this.divider,
    required this.pageBackground,
    required this.fieldBackground,
    required this.fieldDisabledBackground,
    required this.success,
    required this.warning,
    required this.noticeBackground,
    required this.noticeForeground,
    required this.infoBackground,
    required this.infoForeground,
  });

  /// القيم الحالية للتطبيق حرفياً — بلا أي تغيير بصري.
  static const AppSemanticColors light = AppSemanticColors(
    textPrimary: AppPalette.ink900,
    textSecondary: AppPalette.slate500,
    textHint: AppPalette.grey500,
    border: AppPalette.grey200,
    divider: AppPalette.grey300,
    pageBackground: AppPalette.canvas,
    fieldBackground: AppPalette.white,
    fieldDisabledBackground: AppPalette.grey100,
    success: AppPalette.green600,
    warning: AppPalette.amber700,
    noticeBackground: AppPalette.amber50,
    noticeForeground: AppPalette.amber700,
    infoBackground: AppPalette.blue50,
    infoForeground: AppPalette.navy800,
  );

  /// نسخة داكنة أوّلية — بتنضبط فعلياً بالمرحلة 3.
  static const AppSemanticColors dark = AppSemanticColors(
    textPrimary: AppPalette.darkTextPrimary,
    textSecondary: AppPalette.darkTextSecondary,
    textHint: AppPalette.darkTextSecondary,
    border: AppPalette.darkBorder,
    divider: AppPalette.darkBorder,
    pageBackground: AppPalette.darkCanvas,
    fieldBackground: AppPalette.darkSurfaceElevated,
    fieldDisabledBackground: AppPalette.darkSurface,
    success: AppPalette.green600,
    warning: AppPalette.amber700,
    noticeBackground: Color(0xFF2A2213),
    noticeForeground: Color(0xFFE0A93B),
    infoBackground: Color(0xFF16223A),
    infoForeground: Color(0xFF9EC1F5),
  );

  @override
  AppSemanticColors copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? border,
    Color? divider,
    Color? pageBackground,
    Color? fieldBackground,
    Color? fieldDisabledBackground,
    Color? success,
    Color? warning,
    Color? noticeBackground,
    Color? noticeForeground,
    Color? infoBackground,
    Color? infoForeground,
  }) {
    return AppSemanticColors(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      pageBackground: pageBackground ?? this.pageBackground,
      fieldBackground: fieldBackground ?? this.fieldBackground,
      fieldDisabledBackground:
          fieldDisabledBackground ?? this.fieldDisabledBackground,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      noticeBackground: noticeBackground ?? this.noticeBackground,
      noticeForeground: noticeForeground ?? this.noticeForeground,
      infoBackground: infoBackground ?? this.infoBackground,
      infoForeground: infoForeground ?? this.infoForeground,
    );
  }

  /// بتخلّي التبديل بين الثيمين متدرّج بدل ما يقفز.
  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;

    return AppSemanticColors(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      fieldBackground: Color.lerp(fieldBackground, other.fieldBackground, t)!,
      fieldDisabledBackground: Color.lerp(
        fieldDisabledBackground,
        other.fieldDisabledBackground,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      noticeBackground: Color.lerp(
        noticeBackground,
        other.noticeBackground,
        t,
      )!,
      noticeForeground: Color.lerp(
        noticeForeground,
        other.noticeForeground,
        t,
      )!,
      infoBackground: Color.lerp(infoBackground, other.infoBackground, t)!,
      infoForeground: Color.lerp(infoForeground, other.infoForeground, t)!,
    );
  }
}
