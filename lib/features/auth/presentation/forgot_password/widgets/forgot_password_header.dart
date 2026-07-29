import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot Password',
          style: AppTextStyles.f32W600Black.copyWith(fontSize: 24.sp),
        ),
        SizedBox(height: 12.h),
        Text(
          "Enter your email address and we'll send you a code to reset your password.",
          style: AppTextStyles.f16W400Black.copyWith(fontSize: 13.sp),
        ),
      ],
    );
  }
}
