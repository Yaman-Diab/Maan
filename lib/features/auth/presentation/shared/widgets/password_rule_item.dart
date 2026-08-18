import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

class PasswordRuleItem extends StatelessWidget {
  const PasswordRuleItem({
    super.key,
    required this.isValid,
    required this.text,
  });

  final bool isValid;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = isValid ? context.scheme.primary : context.colors.textPrimary;
    final iconColor = isValid
        ? context.scheme.primary
        : context.colors.noticeForeground;

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 180),
      style: context.texts.f12W400SecColor.copyWith(
        color: color,
        fontSize: 12.sp,
        decoration: isValid ? TextDecoration.lineThrough : TextDecoration.none,
        decorationColor: color,
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              isValid ? Icons.check_circle_outline : Icons.cancel_outlined,
              key: ValueKey(isValid),
              size: 14.sp,
              color: iconColor,
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
