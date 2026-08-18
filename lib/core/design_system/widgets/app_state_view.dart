// -------------------------
// App State View
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_spacing.dart';
import '../app_theme_context.dart';

/// عرض حالة فاضية أو خطأ — أيقونة + عنوان اختياري + نص + إجراء اختياري.
///
/// انكتب مع شاشات الأخبار/المشاريع/الرئيسية بنفس اللحظة (تلات مستهلكين
/// دفعة وحدة) بدل ما ينتسخ تلات مرات — نفس قاعدة `AppCard`، بس مطبّقة
/// **قبل** التكرار لا بعده.
///
/// ⚠️ الشاشات الأقدم (الشكاوى، المهارات، خدمات البلدية) لسه عندها
/// نسخها الخاصة — نقلها لهون تنظيف مستقل، مش شرط لأي ميزة جديدة.
class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    required this.icon,
    this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.compact = false,
  });

  final IconData icon;
  final String? title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  /// نسخة مصغّرة تصلح جوّا قسم من شاشة (مثلاً فشل الأخبار بالرئيسية)
  /// بدل ما تاخد الشاشة كاملة.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 16.w : 32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? 28.sp : 56.sp,
            color: iconColor ?? colors.textHint,
          ),
          SizedBox(height: compact ? 7.h : 14.h),
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: context.texts.f16W500Black.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: compact
                ? context.texts.f12W400SecColor
                : context.texts.f14W400HintColor.copyWith(
                    color: colors.textSecondary,
                    height: 1.6,
                  ),
          ),
          if (onAction != null && actionLabel != null) ...[
            SizedBox(height: compact ? 8.h : AppSpacing.lg.h),
            if (compact)
              TextButton(onPressed: onAction, child: Text(actionLabel!))
            else
              SizedBox(
                height: 52.h,
                child: FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    minimumSize: Size(180.w, 52.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md.r),
                    ),
                  ),
                  child: Text(actionLabel!),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
