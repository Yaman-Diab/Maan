import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome Back', style: AppTextStyles.f32W600Black),
        SizedBox(height: 12.h),
        Text(
          'Sign in to contribute to your community and track your activities.',
          style: AppTextStyles.f16W400Black.copyWith(fontSize: 16.sp),
        ),
      ],
    );
  }
}
