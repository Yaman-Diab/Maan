import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

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
    this.fillColor,
    this.onChanged,
    this.onTap,
    this.textInputAction = TextInputAction.next,
    this.enabledBorderColor,
    this.radius = 12,
    this.enabled = true,
    this.readOnly = false,
    this.width,
    this.autofillHints,
    this.maxLength,
    this.digitsOnly = false,
    this.maxLines = 1,
    this.minLines,
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
  /// `null` يعني خُذ اللون من الثيم — راجع `AppButton` لنفس النمط.
  final Color? enabledBorderColor;
  final double radius;
  final bool enabled;
  final bool readOnly;
  final double? width;
  final Iterable<String>? autofillHints;

  /// حد أقصى لعدد الأحرف — يمنع الكتابة/اللصق بعده مباشرة عند مصدره
  /// (`LengthLimitingTextInputFormatter`)، لا رسالة تحقّق بعد الإدخال.
  /// بلا عدّاد أحرف مرسوم: التصميم ما فيه هالعنصر، فـ`counterText: ''`
  /// بتلغي عدّاد Flutter الافتراضي.
  final int? maxLength;

  /// بيرفض أي حرف مش رقم عند الكتابة/اللصق — للرقم الوطني.
  final bool digitsOnly;

  /// `1` (الافتراضي) لحقل سطر واحد. أكبر منها لصناديق نص متعددة
  /// الأسطر (وصف شكوى، ملاحظات) — الحشوة الرأسية والحدود نفسها.
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final borderColor = enabledBorderColor ?? scheme.outline;

    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        cursorColor: scheme.primary,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        textInputAction: textInputAction,
        keyboardType: keyBoardType,
        onChanged: onChanged,
        autofillHints: autofillHints,
        obscureText: obscureText,
        maxLines: maxLines,
        minLines: minLines,
        validator: validationMessage,
        inputFormatters: !digitsOnly && maxLength == null
            ? null
            : [
                if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
                if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
              ],
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 16.w,
          ),
          counterText: maxLength == null ? null : '',
          fillColor: fillColor ?? context.colors.fieldBackground,
          filled: true,
          hintText: hintText,
          hintStyle: context.texts.f14W600HintColor,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius.r),
            borderSide: BorderSide(color: scheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius.r),
            borderSide: BorderSide(color: scheme.error),
          ),
          errorStyle: TextStyle(
            color: scheme.error,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius.r),
            borderSide: BorderSide(color: borderColor),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius.r),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius.r),
            borderSide: BorderSide(color: scheme.primary, width: 2.w),
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
