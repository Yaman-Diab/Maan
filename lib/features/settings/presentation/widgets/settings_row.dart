// -------------------------
// Settings Row
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_theme_context.dart';

/// صف عام لكل أسطر شاشة الإعدادات — أذونات، حول التطبيق، تسجيل خروج،
/// حذف حساب. الفرق بين الحالات بالألوان والأيقونة بس، مش بالبنية.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    this.leadingIcon,
    this.iconBadgeColor,
    this.iconColor,
    required this.label,
    this.labelColor,
    this.trailing,
    this.showChevron = true,
    this.chevronColor,
    this.onTap,
  });

  final IconData? leadingIcon;

  /// لون خلفية الشارة المربّعة خلف الأيقونة — `null` يعني أيقونة عارية
  /// بلا شارة (تسجيل الخروج، حذف الحساب).
  final Color? iconBadgeColor;
  final Color? iconColor;

  final String label;
  final Color? labelColor;

  /// عنصر إضافي قبل السهم — نص قيمة (رقم الإصدار) مثلاً.
  final Widget? trailing;

  final bool showChevron;
  final Color? chevronColor;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              if (iconBadgeColor != null)
                Container(
                  width: 36.w,
                  height: 36.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBadgeColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    leadingIcon,
                    size: 21.sp,
                    color: iconColor ?? context.scheme.primary,
                  ),
                )
              else
                Icon(
                  leadingIcon,
                  size: 22.sp,
                  color: iconColor ?? colors.textPrimary,
                ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Text(
                label,
                style: context.texts.f16W500Black.copyWith(
                  fontSize: 14.5.sp,
                  color: labelColor ?? colors.textPrimary,
                ),
              ),
            ),
            if (trailing != null) ...[SizedBox(width: 12.w), trailing!],
            if (showChevron) ...[
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 22.sp,
                color: chevronColor ?? colors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// فاصل رفيع بين صفوف نفس البطاقة — بادئ من نهاية الأيقونة، مش من
/// حافة البطاقة، متل باقي فواصل التطبيق.
class SettingsRowDivider extends StatelessWidget {
  const SettingsRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 16.w),
      child: Divider(height: 1.h, thickness: 1.h, color: context.colors.divider),
    );
  }
}
