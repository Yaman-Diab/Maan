import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_colors.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    this.buttonWidth = 353,
    this.buttonHeight = 52,
    required this.buttonText,
    required this.buttonOnPressed,
    this.textColor = AppColors.white,
    this.buttonColor = AppColors.primaryColor,
    this.buttonColorSide = AppColors.primaryColor,
    super.key,
  });

  final Color buttonColor;
  final Color buttonColorSide;
  final Color textColor;
  final String buttonText;
  final VoidCallback? buttonOnPressed;
  final double buttonWidth;
  final double buttonHeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => buttonOnPressed!(),
      child: Container(
        width: buttonWidth.w,
        height: 56.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: buttonColorSide),
          boxShadow: [
            BoxShadow(
              color: const Color(0x66000000),
              offset: const Offset(0, 4),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Text(
          buttonText,
          style: AppTextStyles.f16W600White.copyWith(color: textColor),
        ),
      ),
    );
  }
}
