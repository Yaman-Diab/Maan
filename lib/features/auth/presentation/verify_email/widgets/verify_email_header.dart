import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

class VerifyEmailHeader extends StatelessWidget {
  const VerifyEmailHeader({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Verify Your Email',
          textAlign: TextAlign.center,
          style: AppTextStyles.f32W600Black.copyWith(fontSize: 25.sp),
        ),
        SizedBox(height: 14.h),
        Text(
          'A verification code has been sent to your email.',
          textAlign: TextAlign.center,
          style: AppTextStyles.f14W400GreyColor,
        ),
        SizedBox(height: 3.h),
        Text(
          email,
          textAlign: TextAlign.center,
          style: AppTextStyles.f14W400Primary,
        ),
        SizedBox(height: 3.h),
        Text(
          'Please check your inbox or spam folder.',
          textAlign: TextAlign.center,
          style: AppTextStyles.f14W400GreyColor,
        ),
      ],
    );
  }
}
