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

  /// خلفية خفيفة بلون الهوية — أيقونات مؤطّرة وشارات.
  final Color brandSurface;

  /// نفس الفكرة بلون النجاح — شارة «موثّق».
  final Color successSurface;

  /// مسار شريط التقدّم الفاضي (الجزء اللي لسه ما تعبّى).
  final Color trackBackground;

  // صندوق التنبيه (شروط الاستخدام)
  final Color noticeBackground;
  final Color noticeForeground;

  // صندوق المساعدة (معلومات)
  final Color infoBackground;
  final Color infoForeground;

  /// تدرّج خلفية شاشة البداية — من الأعلى للأسفل، والنهاية
  /// [pageBackground] فما إلها توكن ثالث.
  final Color splashGradientTop;
  final Color splashGradientMiddle;

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
    required this.brandSurface,
    required this.successSurface,
    required this.trackBackground,
    required this.noticeBackground,
    required this.noticeForeground,
    required this.infoBackground,
    required this.infoForeground,
    required this.splashGradientTop,
    required this.splashGradientMiddle,
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
    brandSurface: AppPalette.teal600Tint10,
    successSurface: AppPalette.green600Tint10,
    trackBackground: AppPalette.grey100,
    noticeBackground: AppPalette.amber50,
    noticeForeground: AppPalette.amber700,
    infoBackground: AppPalette.blue50,
    infoForeground: AppPalette.navy800,
    splashGradientTop: AppPalette.mist100,
    splashGradientMiddle: AppPalette.mist50,
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
    // نسخة الهوية المفتوحة، لأن teal600 بيختفي فوق سطح داكن.
    brandSurface: AppPalette.teal400Tint10,
    successSurface: AppPalette.green600Tint10,
    trackBackground: AppPalette.darkBorder,
    noticeBackground: Color(0xFF2A2213),
    noticeForeground: Color(0xFFE0A93B),
    infoBackground: Color(0xFF16223A),
    infoForeground: Color(0xFF9EC1F5),
    splashGradientTop: AppPalette.darkSurface,
    splashGradientMiddle: AppPalette.darkSurfaceElevated,
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
    Color? brandSurface,
    Color? successSurface,
    Color? trackBackground,
    Color? noticeBackground,
    Color? noticeForeground,
    Color? infoBackground,
    Color? infoForeground,
    Color? splashGradientTop,
    Color? splashGradientMiddle,
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
      brandSurface: brandSurface ?? this.brandSurface,
      successSurface: successSurface ?? this.successSurface,
      trackBackground: trackBackground ?? this.trackBackground,
      noticeBackground: noticeBackground ?? this.noticeBackground,
      noticeForeground: noticeForeground ?? this.noticeForeground,
      infoBackground: infoBackground ?? this.infoBackground,
      infoForeground: infoForeground ?? this.infoForeground,
      splashGradientTop: splashGradientTop ?? this.splashGradientTop,
      splashGradientMiddle: splashGradientMiddle ?? this.splashGradientMiddle,
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
      brandSurface: Color.lerp(brandSurface, other.brandSurface, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      trackBackground: Color.lerp(trackBackground, other.trackBackground, t)!,
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
      splashGradientTop: Color.lerp(
        splashGradientTop,
        other.splashGradientTop,
        t,
      )!,
      splashGradientMiddle: Color.lerp(
        splashGradientMiddle,
        other.splashGradientMiddle,
        t,
      )!,
    );
  }
}
