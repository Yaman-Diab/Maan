// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:maan/core/design_system/app_colors.dart';
// import 'package:maan/core/design_system/app_text_styles.dart';

// class CustomTextFormField extends StatelessWidget {
//   const CustomTextFormField({
//     super.key,
//     required this.controller,
//     required this.validationMessage,
//     required this.keyBoardType,
//     this.hintText,
//     this.suffixIcon,
//     this.prefixIcon,
//     this.obscureText = false,
//     this.fillColor = AppColors.backgroundColor,
//     this.onChanged,
//     this.textInputAction = TextInputAction.next,
//     this.enabledBorderColor = AppColors.borderColor,
//     this.radius = 12,
//     this.enabled = true,
//     this.readOnly = false,
//   });

//   final String? hintText;
//   final TextEditingController controller;
//   final Widget? suffixIcon;
//   final Widget? prefixIcon;
//   final bool obscureText;
//   final String? Function(String?)? validationMessage;
//   final TextInputType keyBoardType;
//   final Color? fillColor;
//   final void Function(String)? onChanged;
//   final TextInputAction? textInputAction;
//   final Color enabledBorderColor;
//   final double radius;
//   final bool enabled;
//   final bool readOnly;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 328.w,
//       // height: 52.h,
//       child: TextFormField(
//         controller: controller,
//         cursorColor: AppColors.primaryColor,
//         enabled: enabled,
//         readOnly: readOnly,

//         textInputAction: textInputAction,
//         keyboardType: keyBoardType,
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           contentPadding: EdgeInsets.symmetric(
//             vertical: 12.h,
//             horizontal: 16.w,
//           ),
//           fillColor: fillColor,
//           filled: true,
//           hintText: hintText,
//           hintStyle: AppTextStyles.f16W500HintColor,
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(radius.r),
//             borderSide: BorderSide(color: AppColors.errorColor),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(radius.r),
//             borderSide: BorderSide(color: AppColors.errorColor),
//           ),
//           errorStyle: TextStyle(
//             color: AppColors.errorColor,
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w400,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(radius.r),
//             borderSide: BorderSide(color: enabledBorderColor),
//           ),
//           disabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(radius.r),
//             borderSide: BorderSide(color: enabledBorderColor),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(radius.r),
//             borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
//           ),
//           suffixIcon: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 4.0.w),
//             child: suffixIcon,
//           ),
//           suffixIconConstraints: BoxConstraints(
//             minHeight: 18.h,
//             minWidth: 22.w,
//           ),
//           prefixIcon: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 8.0.w),
//             child: prefixIcon,
//           ),
//           prefixIconConstraints: BoxConstraints(
//             minHeight: 23.h,
//             minWidth: 17.w,
//           ),
//         ),
//         obscureText: obscureText,
//         validator: validationMessage,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_colors.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.validationMessage,
    required this.keyBoardType,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.obscureText = false,
    this.fillColor = AppColors.backgroundColor,
    this.onChanged,
    this.onTap,
    this.textInputAction = TextInputAction.next,
    this.enabledBorderColor = AppColors.borderColor,
    this.radius = 12,
    this.enabled = true,
    this.readOnly = false,
    this.width,
    this.autofillHints,
  });

  final String? hintText;
  final TextEditingController controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validationMessage;
  final TextInputType keyBoardType;
  final Color? fillColor;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final Color enabledBorderColor;
  final double radius;
  final bool enabled;
  final bool readOnly;
  final double? width;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        cursorColor: AppColors.primaryColor,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        textInputAction: textInputAction,
        keyboardType: keyBoardType,
        onChanged: onChanged,
        autofillHints: autofillHints,
        obscureText: obscureText,
        validator: validationMessage,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 16.w,
          ),
          fillColor: fillColor,
          filled: true,
          hintText: hintText,
          hintStyle: AppTextStyles.f14W600HintColor,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius.r),
            borderSide: const BorderSide(color: AppColors.errorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius.r),
            borderSide: const BorderSide(color: AppColors.errorColor),
          ),
          errorStyle: TextStyle(
            color: AppColors.errorColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius.r),
            borderSide: BorderSide(color: enabledBorderColor),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius.r),
            borderSide: BorderSide(color: enabledBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius.r),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
          ),
          suffixIcon: suffixIcon == null
              ? null
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                  child: suffixIcon,
                ),
          suffixIconConstraints: BoxConstraints(
            minHeight: 18.h,
            minWidth: 22.w,
          ),
          prefixIcon: prefixIcon == null
              ? null
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                  child: prefixIcon,
                ),
          prefixIconConstraints: BoxConstraints(
            minHeight: 23.h,
            minWidth: 17.w,
          ),
        ),
      ),
    );
  }
}
