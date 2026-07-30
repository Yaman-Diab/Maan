import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

class VerifyEmailHeader extends StatelessWidget {
  const VerifyEmailHeader({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'verify_your_email'.tr(),
          textAlign: TextAlign.center,
          style: context.texts.f32W600Black.copyWith(fontSize: 25.sp),
        ),
        SizedBox(height: 14.h),
        Text(
          'verify_email_sent_notice'.tr(),
          textAlign: TextAlign.center,
          style: context.texts.f14W400GreyColor,
        ),
        SizedBox(height: 3.h),
        Text(
          email,
          textAlign: TextAlign.center,
          style: context.texts.f14W400Primary,
        ),
        SizedBox(height: 3.h),
        Text(
          'verify_email_check_spam'.tr(),
          textAlign: TextAlign.center,
          style: context.texts.f14W400GreyColor,
        ),
      ],
    );
  }
}
