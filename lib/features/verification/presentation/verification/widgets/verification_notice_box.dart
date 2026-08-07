// -------------------------
// Verification Notice Boxes
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';

/// صندوق «تنبيه مهم» + شروط الصورة الثلاثة.
///
/// نفس المحتوى بيظهر بمكانين (أعلى النموذج، و«قبل إعادة الإرسال» بعرض
/// الرفض)، فبيتعرّف مرة وبياخد **النص المترجَم** للعنوان.
///
/// ⚠️ العنوان بيوصل نصاً لا مفتاحاً، والشروط مكتوبة بـ`.tr()` حرفية
/// متتالية لا بحلقة على قائمة مفاتيح: ماسح الترجمة بيتطلّب المفتاح يكون
/// نصاً حرفياً قبل `.tr()` مباشرة — راجع `CLAUDE.md` › الترجمة.
class VerificationRulesBox extends StatelessWidget {
  const VerificationRulesBox({super.key, this.title});

  /// نص العنوان مترجَماً — `null` يعني «تنبيه مهم» تبع النموذج.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.sm.w),
      decoration: BoxDecoration(
        color: colors.noticeBackground,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18.sp,
                color: colors.noticeForeground,
              ),
              SizedBox(width: AppSpacing.xs.w),
              Expanded(
                child: Text(
                  title ?? 'verification_important'.tr(),
                  style: context.texts.f14W600Black.copyWith(
                    color: colors.noticeForeground,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs.h),
          _Rule(text: 'verification_rule_clear_image'.tr()),
          _Rule(text: 'verification_rule_notified'.tr()),
          _Rule(text: 'verification_rule_matches_id'.tr()),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xxs.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 15.sp,
            color: colors.noticeForeground,
          ),
          SizedBox(width: AppSpacing.xs.w),
          Expanded(
            child: Text(
              text,
              style: context.texts.f12W400SecColor.copyWith(
                color: colors.noticeForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// صندوق معلومة أزرق — ملاحظة محايدة لا تحذير. بياخد **النص المترجَم**
/// لنفس سبب [VerificationRulesBox].
class VerificationInfoBox extends StatelessWidget {
  const VerificationInfoBox({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.sm.w),
      decoration: BoxDecoration(
        color: colors.infoBackground,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18.sp,
            color: colors.infoForeground,
          ),
          SizedBox(width: AppSpacing.xs.w),
          Expanded(
            child: Text(
              message,
              style: context.texts.f12W400SecColor.copyWith(
                color: colors.infoForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
