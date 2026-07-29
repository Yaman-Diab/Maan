import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_text_styles.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    this.buttonWidth = 353,
    this.buttonHeight = 52,
    required this.buttonText,
    required this.buttonOnPressed,
    this.textColor,
    this.buttonColor,
    this.buttonColorSide,
    super.key,
  });

  /// كلها اختيارية: القيمة الافتراضية بتنقرأ من الثيم وقت البناء بدل ما
  /// تكون ثابتة بالـ constructor، فبتتبدّل مع الثيم تلقائياً.
  final Color? buttonColor;
  final Color? buttonColorSide;
  final Color? textColor;

  final String buttonText;
  final VoidCallback? buttonOnPressed;
  final double buttonWidth;
  final double buttonHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    final background = buttonColor ?? scheme.primary;
    final borderColor = buttonColorSide ?? scheme.primary;
    final foreground = textColor ?? scheme.onPrimary;

    return GestureDetector(
      onTap: () => buttonOnPressed!(),
      child: Container(
        width: buttonWidth.w,
        height: 56.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: scheme.scrim,
              offset: const Offset(0, 4),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Text(
          buttonText,
          style: AppTextStyles.f16W600White.copyWith(color: foreground),
        ),
      ),
    );
  }
}
