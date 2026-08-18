// -------------------------
// Home Banners
// -------------------------

import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';

/// بانر «وثّق حسابك» — بيظهر لغير الموثّق بس.
class HomeVerifyBanner extends StatelessWidget {
  const HomeVerifyBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return _HomeBanner(
      onTap: onTap,
      background: context.colors.brandSurface,
      borderColor: scheme.primary,
      iconBackground: scheme.primary,
      icon: Icons.verified_user_rounded,
      iconColor: scheme.onPrimary,
      title: 'home_verify_title'.tr(),
      titleColor: context.colors.textPrimary,
      subtitle: 'home_verify_sub'.tr(),
      chevronColor: scheme.primary,
    );
  }
}

/// بلاغ طارئ — **منفصل عن «تقديم شكوى» العادي وأبرز منه بصرياً**.
///
/// السبب مش تجميلي: الطارئة بالباك اند بتُنشر فوراً بلا مراجعة، بينما
/// الفردية والجماعية بتنتظر موافقة موظّف. النص بيوضّح إنها للحالات
/// العاجلة بس حتى ما تُستخدم كاختصار سريع لشكوى عادية.
class HomeEmergencyBanner extends StatelessWidget {
  const HomeEmergencyBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return _HomeBanner(
      onTap: onTap,
      background: scheme.errorContainer,
      borderColor: scheme.error,
      iconBackground: scheme.error,
      icon: Icons.warning_rounded,
      iconColor: scheme.onError,
      title: 'home_emergency_title'.tr(),
      titleColor: scheme.error,
      titleWeight: FontWeight.w700,
      subtitle: 'home_emergency_sub'.tr(),
      chevronColor: scheme.error,
    );
  }
}

class _HomeBanner extends StatelessWidget {
  const _HomeBanner({
    required this.onTap,
    required this.background,
    required this.borderColor,
    required this.iconBackground,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.subtitle,
    required this.chevronColor,
    this.titleWeight = FontWeight.w600,
  });

  final VoidCallback onTap;
  final Color background;
  final Color borderColor;
  final Color iconBackground;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final FontWeight titleWeight;
  final String subtitle;
  final Color chevronColor;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
        ),
        child: Row(
          children: [
            Container(
              width: 45.w,
              height: 45.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 25.sp, color: iconColor),
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: titleWeight,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: context.texts.f12W400SecColor.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
              size: 22.sp,
              color: chevronColor,
            ),
          ],
        ),
      ),
    );
  }
}
