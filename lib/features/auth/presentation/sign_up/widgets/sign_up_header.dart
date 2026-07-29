import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Contributing',
          style: context.texts.f32W600Black,
        ),
        SizedBox(height: 8.h),
        Text(
          'Be part of improving your community and driving positive change.',
          style: context.texts.f16W400Black.copyWith(fontSize: 16.sp),
        ),
      ],
    );
  }
}
