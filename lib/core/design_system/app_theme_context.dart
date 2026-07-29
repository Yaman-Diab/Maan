// -------------------------
// App Theme Context
// -------------------------

import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_semantic_colors.dart';
import 'app_text_styles.dart';

/// وصول مختصر لتوكنات الثيم من أي widget.
///
/// ```dart
/// Container(color: context.colors.noticeBackground)
/// Text('...', style: TextStyle(color: context.scheme.primary))
/// ```
///
/// بترجّع الثيم الفاتح كقيمة احتياطية بدل ما تنهار لو ما كان الامتداد
/// مسجّل — مثلاً بـ widget test بيبني `MaterialApp` بلا ثيم التطبيق.
extension AppThemeContext on BuildContext {
  AppSemanticColors get colors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;

  /// أنماط نصوص التطبيق: `context.texts.f16W500Black`.
  ///
  /// القيمة الاحتياطية بتنبنى وقت الطلب — يعني `.sp` بتنحسب على المقاس
  /// الحالي، مش مجمّدة.
  AppTextStyles get texts =>
      Theme.of(this).extension<AppTextStyles>() ??
      AppTextStyles.from(
        colors: AppSemanticColors.light,
        scheme: const ColorScheme.light(
          primary: AppPalette.teal600,
          secondary: AppPalette.amber700,
        ),
      );

  /// ألوان Material القياسية: `primary`, `error`, `surface`, `outline`...
  ColorScheme get scheme => Theme.of(this).colorScheme;
}
