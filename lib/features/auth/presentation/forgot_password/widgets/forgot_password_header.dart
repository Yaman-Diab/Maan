import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'forgot_password_title'.tr(),
          style: context.texts.f32W600Black.copyWith(fontSize: 24.sp),
        ),
        SizedBox(height: 12.h),
        Text(
          'forgot_password_subtitle'.tr(),
          style: context.texts.f16W400Black.copyWith(fontSize: 13.sp),
        ),
      ],
    );
  }
}
