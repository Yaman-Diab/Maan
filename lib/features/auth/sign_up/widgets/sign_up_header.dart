import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Contributing',
          style: AppTextStyles.f32W600Black,
        ),
        SizedBox(height: 8.h),
        Text(
          'Be part of improving your community and driving positive change.',
          style: AppTextStyles.f16W400Black.copyWith(fontSize: 16.sp),
        ),
      ],
    );
  }
}
