import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome Back', style: context.texts.f32W600Black),
        SizedBox(height: 12.h),
        Text(
          'Sign in to contribute to your community and track your activities.',
          style: context.texts.f16W400Black.copyWith(fontSize: 16.sp),
        ),
      ],
    );
  }
}
