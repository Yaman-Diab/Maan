// -------------------------
// Skills Summary Card
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_card.dart';

/// بطاقة نسبة التوثيق أعلى قائمة المهارات — نسبة الشهادات المعتمدة من
/// إجمالي المهارات + شريط تقدّم + ثلاث إحصائيات مصغّرة.
class SkillsSummaryCard extends StatelessWidget {
  const SkillsSummaryCard({
    super.key,
    required this.approved,
    required this.pending,
    required this.noCertificate,
    required this.total,
  });

  final int approved;
  final int pending;
  final int noCertificate;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;
    final percentage = total == 0 ? 0 : ((approved / total) * 100).round();

    return AppCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: colors.brandSurface,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 19.sp,
                  color: scheme.primary,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'skills_summary_title'.tr(),
                      style: context.texts.f14W600Black.copyWith(
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'skills_summary_line'.tr(
                        namedArgs: {'approved': '$approved', 'total': '$total'},
                      ),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: Container(
              height: 6.h,
              color: colors.trackBackground,
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: percentage / 100,
                child: Container(color: scheme.primary),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  icon: Icons.check_circle_rounded,
                  value: approved,
                  label: 'skills_stat_approved'.tr(),
                  color: colors.success,
                  background: colors.successSurface,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _Stat(
                  icon: Icons.schedule_rounded,
                  value: pending,
                  label: 'skills_stat_pending'.tr(),
                  color: colors.noticeForeground,
                  background: colors.noticeBackground,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _Stat(
                  icon: Icons.upload_file_rounded,
                  value: noCertificate,
                  label: 'skills_stat_none'.tr(),
                  color: colors.textSecondary,
                  background: colors.fieldDisabledBackground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 5.w),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5.sp,
                color: color.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
