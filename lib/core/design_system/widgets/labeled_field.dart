import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_text_styles.dart';

/// حقل مع عنوان فوقه.
///
/// كانت في أربع نسخ منه — وحدة بكل شاشة auth — بتختلف بحجم خط العنوان
/// وبالمسافة تحته فقط. صار واحد، والشاشات بتمرّر فروقاتها.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.labelStyle,
    this.gap = 10,
  });

  final String label;
  final Widget child;
  final TextStyle? labelStyle;

  /// المسافة بين العنوان والحقل، بوحدات `ScreenUtil`.
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle ?? AppTextStyles.f14W600Black),
        SizedBox(height: gap.h),
        child,
      ],
    );
  }
}
