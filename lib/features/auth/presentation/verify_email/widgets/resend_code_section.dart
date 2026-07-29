import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

class ResendCodeSection extends StatelessWidget {
  const ResendCodeSection({
    super.key,
    required this.remainingSeconds,
    required this.canResend,
    required this.isResending,
    required this.onResendTap,
  });

  final int remainingSeconds;
  final bool canResend;
  final bool isResending;
  final VoidCallback onResendTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.f14W400GreyColor,
            children: [
              const TextSpan(text: 'You can resend the code in '),
              TextSpan(
                text: '$remainingSeconds',
                style: AppTextStyles.f14W400Primary.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: ' seconds'),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: canResend ? onResendTap : null,
          child: Opacity(
            opacity: canResend ? 1 : 0.55,
            child: Text(
              isResending ? 'Sending...' : 'Resend code',
              style: AppTextStyles.f14W400PrimaryUnderline.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
