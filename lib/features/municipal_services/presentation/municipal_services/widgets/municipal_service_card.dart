// -------------------------
// Municipal Service Card
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../domain/entities/municipal_service.dart';

/// بطاقة خدمة بلدية — للعرض فقط، بلا أي عنصر تفاعلي يوحي بانضمام أو
/// حجز دور (الشاشة كلها بلا تفاعل مع نظام الطابور الفعلي).
class MunicipalServiceCard extends StatelessWidget {
  const MunicipalServiceCard({super.key, required this.service});

  final MunicipalService service;

  static IconData _iconFor(int serviceId) {
    return switch (serviceId) {
      1 => Icons.description_rounded,
      2 => Icons.architecture_rounded,
      3 => Icons.account_balance_wallet_rounded,
      4 => Icons.campaign_rounded,
      _ => Icons.miscellaneous_services_rounded,
    };
  }

  /// ألوان الشدّة — ثلاث درجات فوق نفس عتبات التصميم (بالدقائق):
  /// قصير ≤15 (هوية)، متوسط ≤35 (كهرماني)، طويل أكتر (برتقالي). كلها
  /// من `ColorScheme`/`AppSemanticColors` الموجودة أصلاً — بلا توكن جديد.
  static ({Color fg, Color bg}) _severity(
    BuildContext context,
    int totalMinutes,
  ) {
    final scheme = context.scheme;
    final colors = context.colors;

    if (totalMinutes <= 15) {
      return (fg: scheme.primary, bg: colors.brandSurface);
    }
    if (totalMinutes <= 35) {
      return (fg: scheme.secondary, bg: colors.noticeBackground);
    }

    return (fg: scheme.tertiary, bg: scheme.tertiary.withValues(alpha: 0.14));
  }

  static String _waitingText(int count) {
    if (count == 1) return 'municipal_service_wait_one'.tr();
    if (count == 2) return 'municipal_service_wait_two'.tr();
    if (count <= 10) {
      return 'municipal_service_wait_few'.tr(namedArgs: {'count': '$count'});
    }

    return 'municipal_service_wait_many'.tr(namedArgs: {'count': '$count'});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;

    if (!service.isActive) {
      return _buildInactive(context);
    }

    final totalMinutes = service.estimatedWaitMinutes;
    final severity = _severity(context, service.hasNoWait ? 0 : totalMinutes);
    // نسبة الشريط من ساعة كاملة — سقف بصري بس، بلا معنى بيزنسي.
    final meterPercent = service.hasNoWait
        ? 0.06
        : (totalMinutes / 60).clamp(0.08, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: colors.brandSurface,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Icon(
                  _iconFor(service.id),
                  size: 25.sp,
                  color: scheme.primary,
                ),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: context.texts.f14W600Black.copyWith(
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.group_rounded,
                          size: 14.sp,
                          color: colors.textSecondary,
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Text(
                            service.hasNoWait
                                ? 'municipal_service_wait_now'.tr()
                                : _waitingText(service.peopleWaiting),
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                constraints: BoxConstraints(minWidth: 60.w),
                padding: EdgeInsets.symmetric(
                  horizontal: service.hasNoWait ? 10.w : 12.w,
                  vertical: service.hasNoWait ? 8.h : 7.h,
                ),
                decoration: BoxDecoration(
                  color: severity.bg,
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: service.hasNoWait
                      ? [
                          Icon(
                            Icons.bolt_rounded,
                            size: 19.sp,
                            color: severity.fg,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'municipal_service_now_badge'.tr(),
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: severity.fg,
                            ),
                          ),
                        ]
                      : [
                          Text(
                            '$totalMinutes',
                            style: TextStyle(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w700,
                              color: severity.fg,
                              height: 1,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'municipal_service_minutes_unit'.tr(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: severity.fg.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                ),
              ),
            ],
          ),
          SizedBox(height: 13.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: Container(
              height: 4.h,
              color: colors.fieldDisabledBackground,
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: meterPercent,
                child: Container(color: severity.fg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInactive(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.fieldDisabledBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Icon(
              _iconFor(service.id),
              size: 25.sp,
              color: colors.textHint,
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: context.texts.f14W600Black.copyWith(
                    fontSize: 15.sp,
                    color: colors.textHint,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.scheme.surface,
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.do_not_disturb_on_rounded,
                        size: 13.sp,
                        color: colors.textHint,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        'municipal_service_unavailable_badge'.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
