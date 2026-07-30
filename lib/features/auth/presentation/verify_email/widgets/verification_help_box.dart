import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

class VerificationHelpBox extends StatelessWidget {
  const VerificationHelpBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: context.colors.infoBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: context.scheme.primary, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'verification_help_title'.tr(),
            style: context.texts.f14W400HintColor.copyWith(
              color: context.colors.infoForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          _HelpLine(text: 'verification_help_step1'.tr()),
          _HelpLine(text: 'verification_help_step2'.tr()),
          _HelpLine(text: 'verification_help_step3'.tr()),
          _HelpLine(text: 'verification_help_step4'.tr()),
          SizedBox(height: 4.h),
          Text(
            'verification_help_missing_title'.tr(),
            style: context.texts.f14W400HintColor.copyWith(
              color: context.colors.infoForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          _HelpLine(text: 'verification_help_check_spam'.tr()),
          _HelpLine(text: 'verification_help_wait_resend'.tr()),
        ],
      ),
    );
  }
}

class _HelpLine extends StatelessWidget {
  const _HelpLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: context.texts.f14W400HintColor.copyWith(
          color: context.colors.infoForeground,
          height: 1.45,
        ),
      ),
    );
  }
}
