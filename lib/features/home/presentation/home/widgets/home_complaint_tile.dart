// -------------------------
// Home Complaint Tile
// -------------------------

import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../complaints/domain/entities/complaint.dart';
import '../../../../complaints/domain/entities/complaint_status.dart';
import '../../../../complaints/presentation/shared/complaint_style.dart';

/// بطاقة شكوى مصغّرة لشريط «آخر شكاواي» — تلخيص لا بطاقة كاملة
/// (بلا تصويت ولا إبلاغ ولا صورة)، وتاب الشكاوى موجود للتفاصيل.
class HomeComplaintTile extends StatelessWidget {
  const HomeComplaintTile({
    super.key,
    required this.complaint,
    required this.onTap,
  });

  final Complaint complaint;
  final VoidCallback onTap;

  static String _statusLabel(ComplaintStatus status) {
    return switch (status) {
      ComplaintStatus.underReview => 'complaint_status_under_review'.tr(),
      ComplaintStatus.inProgress => 'complaint_status_in_progress'.tr(),
      ComplaintStatus.closed => 'complaint_status_closed'.tr(),
      ComplaintStatus.unknown => 'complaint_status_under_review'.tr(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;
    final statusStyle = ComplaintStyle.status(context, complaint.status);
    final categoryStyle = complaint.category == null
        ? null
        : ComplaintStyle.category(context, complaint.category!);
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          boxShadow: AppShadows.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    categoryStyle?.background ?? colors.fieldDisabledBackground,
                borderRadius: BorderRadius.circular(AppRadius.md.r),
              ),
              child: Icon(
                categoryStyle?.icon ?? Icons.campaign_rounded,
                size: 20.sp,
                color: categoryStyle?.foreground ?? colors.textSecondary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusStyle.background,
                      borderRadius: BorderRadius.circular(AppRadius.pill.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusStyle.icon,
                          size: 12.sp,
                          color: statusStyle.foreground,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _statusLabel(complaint.status),
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w600,
                            color: statusStyle.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
              size: 20.sp,
              color: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
