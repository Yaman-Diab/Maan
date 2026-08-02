import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';
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
      textStyle: context.texts.f16W500Black.copyWith(fontSize: 22.sp),
      decoration: BoxDecoration(
        color: context.colors.fieldBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: context.colors.border, width: 1.w),
      ),
    );

    final focusedTheme = baseTheme.copyWith(
      decoration: BoxDecoration(
        color: context.colors.fieldBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: context.scheme.primary, width: 1.4.w),
      ),
    );

    final submittedTheme = baseTheme.copyWith(
      decoration: BoxDecoration(
        color: context.colors.fieldBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: context.colors.border, width: 1.w),
      ),
    );

    final followingTheme = baseTheme.copyWith(
      textStyle: context.texts.f16W500Black.copyWith(
        color: context.colors.divider,
        fontSize: 22.sp,
      ),
      decoration: BoxDecoration(
        color: context.colors.fieldDisabledBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: context.colors.border, width: 1.w),
      ),
    );

    final errorTheme = baseTheme.copyWith(
      decoration: BoxDecoration(
        color: context.colors.fieldBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: context.scheme.error, width: 1.2.w),
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
        color: context.scheme.error,
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
        style: context.texts.f16W500Black.copyWith(
          color: context.colors.textPrimary,
          fontSize: 22.sp,
        ),
      ),
      separatorBuilder: (index) => SizedBox(width: 8.w),
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}
