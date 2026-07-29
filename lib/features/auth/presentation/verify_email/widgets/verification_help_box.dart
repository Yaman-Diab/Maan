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
            'To find your verification code:',
            style: context.texts.f14W400HintColor.copyWith(
              color: context.colors.infoForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          _HelpLine(text: '1. Open your email app or email website.'),
          _HelpLine(text: '2. Look for a new email from the Municipality.'),
          _HelpLine(text: '3. Open the email and find the verification code.'),
          _HelpLine(text: '4. Enter the code in the fields provided.'),
          SizedBox(height: 4.h),
          Text(
            'If you can’t find the email:',
            style: context.texts.f14W400HintColor.copyWith(
              color: context.colors.infoForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          _HelpLine(text: '• Check your Spam or Junk folder.'),
          _HelpLine(text: '• Wait a few minutes and resend the code.'),
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
