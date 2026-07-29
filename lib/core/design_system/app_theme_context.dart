// -------------------------
// App Theme Context
// -------------------------

import 'package:flutter/material.dart';

import 'app_semantic_colors.dart';

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

  /// ألوان Material القياسية: `primary`, `error`, `surface`, `outline`...
  ColorScheme get scheme => Theme.of(this).colorScheme;
}
