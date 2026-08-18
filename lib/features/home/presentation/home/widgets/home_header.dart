// -------------------------
// Home Header
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';

/// ترحيب + مؤشر مواطنة مصغّر + جرس الإشعارات.
///
/// ⚠️ **المؤشر مصغّر عن قصد** — البطاقة الكاملة بشريط تقدّم موجودة
/// بالملف الشخصي؛ هون شارة صغيرة تحفيزية بس بلا تكرار المحتوى.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.firstName,
    required this.citizenshipScore,
    this.unreadNotifications = 0,
  });

  /// `null` للزائر — بيصير الترحيب عاماً بلا اسم.
  final String? firstName;

  /// `null` لو ما وصل الملف الشخصي بعد أو فشل — الشارة بتختفي كلياً
  /// بدل ما تعرض صفراً كاذباً.
  final int? citizenshipScore;

  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 9.w,
                runSpacing: 6.h,
                children: [
                  Text(
                    firstName == null
                        ? 'home_greeting_guest'.tr()
                        : 'home_greeting'.tr(namedArgs: {'name': firstName!}),
                    style: context.texts.f16W500Black.copyWith(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                  if (citizenshipScore != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.brandSurface,
                        borderRadius: BorderRadius.circular(AppRadius.pill.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 14.sp,
                            color: scheme.primary,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'home_citizenship_badge'.tr(
                              namedArgs: {'score': '$citizenshipScore'},
                            ),
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                'home_greeting_sub'.tr(),
                style: context.texts.f12W400SecColor.copyWith(fontSize: 13.sp),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        _NotificationsButton(unreadCount: unreadNotifications),
      ],
    );
  }
}

/// ⚠️ **بلا شاشة قائمة إشعارات** — ما في endpoint مؤكّد لها بعد
/// (حقل `fcm_token` موجود بالباك اند فالإشعارات مخطّط لها، بس بلا
/// عقد قراءة). الزر معروض بالتصميم فبقي، وضغطه ما بيعمل شي لحد ما
/// يجهز المسار.
class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Container(
      width: 44.w,
      height: 44.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: AppShadows.shadowSm,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.notifications_rounded,
            size: 23.sp,
            color: context.colors.textPrimary,
          ),
          if (unreadCount > 0)
            PositionedDirectional(
              top: 2.h,
              end: 2.w,
              child: Container(
                constraints: BoxConstraints(minWidth: 16.w),
                height: 16.w,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.error,
                  borderRadius: BorderRadius.circular(AppRadius.pill.r),
                  border: Border.all(color: scheme.surface, width: 2),
                ),
                child: Text(
                  '$unreadCount',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.onError,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
