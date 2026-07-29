import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onTap,
        child: Text(
          'Forgot Password?',
          style: AppTextStyles.f14W400PrimaryUnderline.copyWith(
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
