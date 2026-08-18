// -------------------------
// Home Quick Actions
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';

/// ثلاثة اختصارات لمسارات موجودة أصلاً.
///
/// ⚠️ «تقديم شكوى» هون هي **العادية** — الطارئة إلها بانرها المنفصل
/// البارز فوق، عن قصد (راجع `HomeEmergencyBanner`).
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({
    super.key,
    required this.onSubmitComplaint,
    required this.onMunicipalServices,
    required this.onSkills,
  });

  final VoidCallback onSubmitComplaint;
  final VoidCallback onMunicipalServices;
  final VoidCallback onSkills;

  @override
  Widget build(BuildContext context) {
    // ⚠️ `stretch` بيحتاج ارتفاع محدود يشتد عليه — والـRow هون قاعد
    // مباشرة جوّا `ListView` عمودي (ارتفاع غير محدود)، فبلا
    // `IntrinsicHeight` بيرمي Flutter "BoxConstraints forces an
    // infinite height" وقت التشغيل الحقيقي (ما بيمسكها `flutter
    // analyze` ولا اختبارات الـCubit، لأنها خطأ layout وقت الرسم لا
    // تحليل ستاتيكي). محتاجينها لأن التسميات بطول مختلف («تقديم شكوى»
    // مقابل «الشهادات والمهارات») ولازم البطاقات الثلاث تتساوى ارتفاعاً.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _QuickAction(
              icon: Icons.rate_review_rounded,
              label: 'home_quick_complaint'.tr(),
              onTap: onSubmitComplaint,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: _QuickAction(
              icon: Icons.account_balance_rounded,
              label: 'home_quick_services'.tr(),
              onTap: onMunicipalServices,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: _QuickAction(
              icon: Icons.workspace_premium_rounded,
              label: 'home_quick_skills'.tr(),
              onTap: onSkills,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: Container(
        padding: EdgeInsets.fromLTRB(8.w, 15.h, 8.w, 13.h),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          boxShadow: AppShadows.shadowSm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colors.brandSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 25.sp, color: scheme.primary),
            ),
            SizedBox(height: 9.h),
            // تسمية طويلة («الشهادات والمهارات») بتصغر بدل ما تكسر
            // ارتفاع البطاقة — نفس إصلاح شبكة التصنيفات بالشكاوى.
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                height: 1.3,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
