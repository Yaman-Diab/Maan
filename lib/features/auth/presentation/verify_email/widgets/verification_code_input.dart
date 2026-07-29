import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_colors.dart';
import 'package:maan/core/design_system/app_text_styles.dart';
import 'package:pinput/pinput.dart';

class VerificationCodeInput extends StatelessWidget {
  const VerificationCodeInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.hasError,
    required this.errorText,
    this.onChanged,
    this.onCompleted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final bool hasError;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) {
    final baseTheme = PinTheme(
      width: 47.w,
      height: 50.h,
      textStyle: AppTextStyles.f16W500Black.copyWith(fontSize: 22.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
    );

    final focusedTheme = baseTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primaryColor, width: 1.4.w),
      ),
    );

    final submittedTheme = baseTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
    );

    final followingTheme = baseTheme.copyWith(
      textStyle: AppTextStyles.f16W500Black.copyWith(
        color: AppColors.greyColor,
        fontSize: 22.sp,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
    );

    final errorTheme = baseTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.errorColor, width: 1.2.w),
      ),
    );

    return Pinput(
      controller: controller,
      focusNode: focusNode,
      length: length,
      defaultPinTheme: baseTheme,
      focusedPinTheme: focusedTheme,
      submittedPinTheme: submittedTheme,
      followingPinTheme: followingTheme,
      errorPinTheme: errorTheme,
      forceErrorState: hasError,
      errorText: errorText,
      errorTextStyle: TextStyle(
        color: AppColors.errorColor,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
      ),
      autofocus: true,
      closeKeyboardWhenCompleted: false,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      preFilledWidget: Text(
        '–',
        style: AppTextStyles.f16W500Black.copyWith(
          color: Colors.black,
          fontSize: 22.sp,
        ),
      ),
      separatorBuilder: (index) => SizedBox(width: 8.w),
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}
