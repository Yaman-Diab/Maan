// -------------------------
// App Text Styles
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_semantic_colors.dart';

/// أنماط النصوص كامتداد ثيم.
///
/// **ليش امتداد بدل ثوابت static؟** كانت الأنماط `static final`، يعني
/// بتتقيّم مرة وحدة عند أول وصول وبتنجمد. وبما إن `.sp` تبع ScreenUtil
/// بتعتمد على أبعاد الشاشة، القيمة كانت بتتجمّد على أول مقاس شافه
/// التطبيق وما بتستجيب لتغيير حجم النافذة ولا للدوران — وهاد بيضرب
/// الاستجابة على التابلت والديسكتوب.
///
/// هلق بتنبنى جوّا `AppTheme` اللي بينبنى جوّا `ScreenUtilInit`، فبيُعاد
/// حساب `.sp` مع كل rebuild. **الأرقام نفسها حرفياً** — اللي تغيّر هو
/// وقت التقييم فقط.
///
/// وكمان الألوان صارت تجي من [AppSemanticColors]، فبتتبدّل مع الثيم
/// الداكن بلا ما يتغير أي موقع استدعاء.
///
/// الاستخدام: `context.texts.f16W500Black`
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  // Font Size 32
  final TextStyle f32W600Black;
  final TextStyle f32W400Black;

  // Font Size 16
  final TextStyle f16W400Black;
  final TextStyle f16W500Black;
  final TextStyle f16W600White;
  final TextStyle f16W400SuccessColorLineThrough;
  final TextStyle f16W400HintColor;
  final TextStyle f16W500HintColor;
  final TextStyle f16W600HintColor;
  final TextStyle f16W500GreyColor;
  final TextStyle f16W500PrimaryUnderline;

  // Font Size 15
  final TextStyle f15W600Primary;

  // Font Size 14
  final TextStyle f14W400PrimaryUnderline;
  final TextStyle f14W400HintColor;
  final TextStyle f14W400GreyColor;
  final TextStyle f14W400Primary;
  final TextStyle f14W600Black;
  final TextStyle f14W600HintColor;

  // Font Size 12
  final TextStyle f12W400SecColor;

  const AppTextStyles({
    required this.f32W600Black,
    required this.f32W400Black,
    required this.f16W400Black,
    required this.f16W500Black,
    required this.f16W600White,
    required this.f16W400SuccessColorLineThrough,
    required this.f16W400HintColor,
    required this.f16W500HintColor,
    required this.f16W600HintColor,
    required this.f16W500GreyColor,
    required this.f16W500PrimaryUnderline,
    required this.f15W600Primary,
    required this.f14W400PrimaryUnderline,
    required this.f14W400HintColor,
    required this.f14W400GreyColor,
    required this.f14W400Primary,
    required this.f14W600Black,
    required this.f14W600HintColor,
    required this.f12W400SecColor,
  });

  /// بتتبنى وقت بناء الثيم — أي جوّا `ScreenUtilInit`، فـ`.sp` صحيحة.
  ///
  /// الأحجام مطابقة للنسخة السابقة رقماً برقم؛ الألوان بس صارت من
  /// التوكنات الدلالية بدل ثوابت `AppColors`.
  factory AppTextStyles.from({
    required AppSemanticColors colors,
    required ColorScheme scheme,
  }) {
    return AppTextStyles(
      f32W600Black: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      f32W400Black: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
      ),
      f16W400Black: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
      ),
      f16W500Black: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
      f16W600White: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: scheme.onPrimary,
      ),
      f16W400SuccessColorLineThrough: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: colors.success,
        decoration: TextDecoration.lineThrough,
      ),
      f16W400HintColor: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: colors.textHint,
      ),
      f16W500HintColor: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: colors.textHint,
      ),
      f16W600HintColor: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: colors.textHint,
      ),
      f16W500GreyColor: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: colors.divider,
      ),
      f16W500PrimaryUnderline: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: scheme.primary,
        decoration: TextDecoration.underline,
      ),
      f15W600Primary: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: scheme.primary,
      ),
      f14W400PrimaryUnderline: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: scheme.primary,
        decoration: TextDecoration.underline,
      ),
      f14W400HintColor: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: colors.textHint,
      ),
      f14W400GreyColor: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      f14W400Primary: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: scheme.primary,
      ),
      f14W600Black: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      f14W600HintColor: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: colors.textHint,
      ),
      f12W400SecColor: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: scheme.secondary,
      ),
    );
  }

  /// `TextTheme` قياسية عشان widgets Material الجاهزة (SnackBar، Dialog،
  /// NavigationBar) تاخد أحجام التطبيق بدل الافتراضية.
  TextTheme toTextTheme() {
    return TextTheme(
      displaySmall: f32W600Black,
      headlineMedium: f32W400Black,
      titleLarge: f16W500Black,
      titleMedium: f16W400Black,
      bodyLarge: f16W400Black,
      bodyMedium: f14W600Black,
      bodySmall: f12W400SecColor,
      labelLarge: f16W600White,
      labelMedium: f14W400HintColor,
    );
  }

  @override
  AppTextStyles copyWith({
    TextStyle? f32W600Black,
    TextStyle? f32W400Black,
    TextStyle? f16W400Black,
    TextStyle? f16W500Black,
    TextStyle? f16W600White,
    TextStyle? f16W400SuccessColorLineThrough,
    TextStyle? f16W400HintColor,
    TextStyle? f16W500HintColor,
    TextStyle? f16W600HintColor,
    TextStyle? f16W500GreyColor,
    TextStyle? f16W500PrimaryUnderline,
    TextStyle? f15W600Primary,
    TextStyle? f14W400PrimaryUnderline,
    TextStyle? f14W400HintColor,
    TextStyle? f14W400GreyColor,
    TextStyle? f14W400Primary,
    TextStyle? f14W600Black,
    TextStyle? f14W600HintColor,
    TextStyle? f12W400SecColor,
  }) {
    return AppTextStyles(
      f32W600Black: f32W600Black ?? this.f32W600Black,
      f32W400Black: f32W400Black ?? this.f32W400Black,
      f16W400Black: f16W400Black ?? this.f16W400Black,
      f16W500Black: f16W500Black ?? this.f16W500Black,
      f16W600White: f16W600White ?? this.f16W600White,
      f16W400SuccessColorLineThrough:
          f16W400SuccessColorLineThrough ?? this.f16W400SuccessColorLineThrough,
      f16W400HintColor: f16W400HintColor ?? this.f16W400HintColor,
      f16W500HintColor: f16W500HintColor ?? this.f16W500HintColor,
      f16W600HintColor: f16W600HintColor ?? this.f16W600HintColor,
      f16W500GreyColor: f16W500GreyColor ?? this.f16W500GreyColor,
      f16W500PrimaryUnderline:
          f16W500PrimaryUnderline ?? this.f16W500PrimaryUnderline,
      f15W600Primary: f15W600Primary ?? this.f15W600Primary,
      f14W400PrimaryUnderline:
          f14W400PrimaryUnderline ?? this.f14W400PrimaryUnderline,
      f14W400HintColor: f14W400HintColor ?? this.f14W400HintColor,
      f14W400GreyColor: f14W400GreyColor ?? this.f14W400GreyColor,
      f14W400Primary: f14W400Primary ?? this.f14W400Primary,
      f14W600Black: f14W600Black ?? this.f14W600Black,
      f14W600HintColor: f14W600HintColor ?? this.f14W600HintColor,
      f12W400SecColor: f12W400SecColor ?? this.f12W400SecColor,
    );
  }

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) return this;

    return AppTextStyles(
      f32W600Black: TextStyle.lerp(f32W600Black, other.f32W600Black, t)!,
      f32W400Black: TextStyle.lerp(f32W400Black, other.f32W400Black, t)!,
      f16W400Black: TextStyle.lerp(f16W400Black, other.f16W400Black, t)!,
      f16W500Black: TextStyle.lerp(f16W500Black, other.f16W500Black, t)!,
      f16W600White: TextStyle.lerp(f16W600White, other.f16W600White, t)!,
      f16W400SuccessColorLineThrough: TextStyle.lerp(
        f16W400SuccessColorLineThrough,
        other.f16W400SuccessColorLineThrough,
        t,
      )!,
      f16W400HintColor: TextStyle.lerp(
        f16W400HintColor,
        other.f16W400HintColor,
        t,
      )!,
      f16W500HintColor: TextStyle.lerp(
        f16W500HintColor,
        other.f16W500HintColor,
        t,
      )!,
      f16W600HintColor: TextStyle.lerp(
        f16W600HintColor,
        other.f16W600HintColor,
        t,
      )!,
      f16W500GreyColor: TextStyle.lerp(
        f16W500GreyColor,
        other.f16W500GreyColor,
        t,
      )!,
      f16W500PrimaryUnderline: TextStyle.lerp(
        f16W500PrimaryUnderline,
        other.f16W500PrimaryUnderline,
        t,
      )!,
      f15W600Primary: TextStyle.lerp(f15W600Primary, other.f15W600Primary, t)!,
      f14W400PrimaryUnderline: TextStyle.lerp(
        f14W400PrimaryUnderline,
        other.f14W400PrimaryUnderline,
        t,
      )!,
      f14W400HintColor: TextStyle.lerp(
        f14W400HintColor,
        other.f14W400HintColor,
        t,
      )!,
      f14W400GreyColor: TextStyle.lerp(
        f14W400GreyColor,
        other.f14W400GreyColor,
        t,
      )!,
      f14W400Primary: TextStyle.lerp(f14W400Primary, other.f14W400Primary, t)!,
      f14W600Black: TextStyle.lerp(f14W600Black, other.f14W600Black, t)!,
      f14W600HintColor: TextStyle.lerp(
        f14W600HintColor,
        other.f14W600HintColor,
        t,
      )!,
      f12W400SecColor: TextStyle.lerp(
        f12W400SecColor,
        other.f12W400SecColor,
        t,
      )!,
    );
  }
}
