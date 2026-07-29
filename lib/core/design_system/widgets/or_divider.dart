import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_theme_context.dart';

/// فاصل "or" بين طرق تسجيل الدخول.
///
/// كانت نسختين متطابقتين إلا بلون الخط.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.color});

  /// `null` يعني لون الفاصل من الثيم.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? context.colors.divider;

    return Row(
      children: [
        Expanded(child: Divider(color: lineColor, thickness: 1.h)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text('or', style: context.texts.f14W400HintColor),
        ),
        Expanded(child: Divider(color: lineColor, thickness: 1.h)),
      ],
    );
  }
}
