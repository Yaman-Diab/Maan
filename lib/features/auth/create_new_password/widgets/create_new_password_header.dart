import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

class CreateNewPasswordHeader extends StatelessWidget {
  const CreateNewPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create a New Password',
          style: AppTextStyles.f32W600Black.copyWith(fontSize: 24.sp),
        ),
        SizedBox(height: 12.h),
        Text(
          'Your account recovery request has been verified successfully. Please create a new password to secure your account. Make sure your password meets the security requirements below, as it will be used to access municipal services and manage your contributions, donations, and reports.',
          style: AppTextStyles.f14W400GreyColor,
        ),
      ],
    );
  }
}
