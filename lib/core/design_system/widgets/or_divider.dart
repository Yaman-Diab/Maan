import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

/// فاصل "or" بين طرق تسجيل الدخول.
///
/// كانت نسختين متطابقتين إلا بلون الخط.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.color = AppColors.borderColor});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: color, thickness: 1.h)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text('or', style: AppTextStyles.f14W400HintColor),
        ),
        Expanded(child: Divider(color: color, thickness: 1.h)),
      ],
    );
  }
}
