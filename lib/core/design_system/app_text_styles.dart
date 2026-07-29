import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Font Size 32
  static TextStyle f32W600Black = TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  /// Font Size 32
  static final TextStyle f32W400Black = TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  /// Font Size 16
  static final TextStyle f16W400Black = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  static final TextStyle f16W600White = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
  static final TextStyle f16W400SuccessColorLineThrough = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.successColor,
    decoration: TextDecoration.lineThrough,
  );

  static final TextStyle f16W500Black = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static final TextStyle f16W400HintColor = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.hintColor,
  );
  static final TextStyle f16W500HintColor = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.hintColor,
  );
  static final TextStyle f16W600HintColor = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.hintColor,
  );
  static final TextStyle f16W500GreyColor = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.greyColor,
  );

  static final TextStyle f16W500PrimaryUnderline = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
    decoration: TextDecoration.underline,
  );

  /// Font Size 15
  static final TextStyle f15W600Primary = TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryColor,
  );

  /// Font Size 14
  static final TextStyle f14W400PrimaryUnderline = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryColor,
    decoration: TextDecoration.underline,
  );

  static final TextStyle f14W400HintColor = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.hintColor,
  );
  static final TextStyle f14W400GreyColor = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.greyColor2,
  );
  static final TextStyle f14W400Primary = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryColor,
  );
  static final TextStyle f14W600Black = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static final TextStyle f14W600HintColor = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.hintColor,
  );


  /// Font Size 12
  static final TextStyle f12W400SecColor = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryColor,
  );
}
