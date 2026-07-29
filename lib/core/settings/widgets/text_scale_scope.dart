// -------------------------
// Text Scale Scope
// -------------------------

import 'package:flutter/material.dart';

import '../cubit/settings_state.dart';

/// بيطبّق تفضيل حجم الخط على الشجرة كاملة.
///
/// بيضرب تفضيل المستخدم بإعداد النظام بدل ما يستبدله: لو استبدلناه،
/// مستخدم مكبّر الخط من إعدادات الجهاز لأسباب إتاحة بيخسر تكبيره أول ما
/// يفتح التطبيق — و`PROJECT_CONTEXT.md` بينص إن الإتاحة إلزامية.
///
/// الحدّان بيحميا التخطيط: تكبير غير محدود بيكسر الأزرار والبطاقات.
class TextScaleScope extends StatelessWidget {
  const TextScaleScope({super.key, required this.scale, required this.child});

  static const double minScale = 0.8;
  static const double maxScale = 1.6;

  final AppTextScale scale;
  final Widget? child;

  /// معزولة عن `build` حتى تنختبر بلا شجرة widgets.
  static double resolveScale({
    required double systemScale,
    required AppTextScale preference,
  }) {
    return (systemScale * preference.factor).clamp(minScale, maxScale);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final combined = resolveScale(
      systemScale: mediaQuery.textScaler.scale(1),
      preference: scale,
    );

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.linear(combined)),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
