// -------------------------
// Complaint Card
// -------------------------

import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/place_name_text.dart';
import '../../../domain/entities/complaint.dart';
import '../../../domain/entities/complaint_status.dart';
import '../../../domain/entities/complaint_type.dart';
import '../../shared/complaint_style.dart';

/// بطاقة شكوى — قائمة المنشورة وشكاواي.
///
/// الطارئة بخلفية `errorContainer` كاملة بدل الأبيض المعتاد — أهم إشارة
/// بصرية بالشاشة، ما بتعتمد على الشارة وحدها.
class ComplaintCard extends StatelessWidget {
  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.canVote,
    required this.onTap,
    required this.onVoteTap,
  });

  final Complaint complaint;
  final bool canVote;
  final VoidCallback onTap;
  final VoidCallback onVoteTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;
    final isEmergency = complaint.type == ComplaintType.emergency;
    final categoryStyle = complaint.category == null
        ? null
        : ComplaintStyle.category(context, complaint.category!);
    final typeStyle = ComplaintStyle.type(context, complaint.type);
    final statusStyle = ComplaintStyle.status(context, complaint.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isEmergency ? scheme.errorContainer : scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: complaint.hasMedia
                        ? colors.fieldDisabledBackground
                        : (categoryStyle?.background ??
                              colors.fieldDisabledBackground),
                    borderRadius: BorderRadius.circular(AppRadius.md.r),
                    border: complaint.hasMedia
                        ? Border.all(color: colors.border)
                        : null,
                  ),
                  child: complaint.hasMedia
                      ? Image.network(
                          complaint.mediaUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Icon(
                            Icons.image_rounded,
                            size: 24.sp,
                            color: colors.textHint,
                          ),
                        )
                      : Icon(
                          categoryStyle?.icon ?? Icons.campaign_rounded,
                          size: 28.sp,
                          color:
                              categoryStyle?.foreground ?? colors.textSecondary,
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.f14W600Black.copyWith(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: [
                          _Chip(
                            icon: typeStyle.icon,
                            label: switch (complaint.type) {
                              ComplaintType.individual =>
                                'complaint_type_individual'.tr(),
                              ComplaintType.collective =>
                                'complaint_type_collective'.tr(),
                              ComplaintType.emergency =>
                                'complaint_type_emergency'.tr(),
                            },
                            background: typeStyle.background,
                            foreground: typeStyle.foreground,
                          ),
                          _Chip(
                            icon: statusStyle.icon,
                            label: _statusLabel(complaint),
                            background: statusStyle.background,
                            foreground: statusStyle.foreground,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 15.sp,
                  color: colors.textSecondary,
                ),
                SizedBox(width: 4.w),
                if (complaint.latitude != null && complaint.longitude != null)
                  Expanded(
                    child: PlaceNameText(
                      latitude: complaint.latitude!,
                      longitude: complaint.longitude!,
                      style: context.texts.f12W400SecColor.copyWith(
                        fontSize: 11.5.sp,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (complaint.createdAt != null) ...[
                  SizedBox(width: 8.w),
                  Text(
                    complaint.createdAt!.toLocal().toString().split(' ').first,
                    style: context.texts.f12W400SecColor.copyWith(
                      fontSize: 11.5.sp,
                      color: colors.textHint,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 10.h),
            Container(height: 1, color: colors.divider),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ⚠️ `Expanded` لا حجم طبيعي — «أعاني من هذه الشكوى»
                // نص أطول بكتير من «صوت» القديمة، وبلا هالتقييد بيرمي
                // RenderFlex overflow على شاشة ضيّقة أو حجم خط أكبر
                // (نفس فئة الباگ الموثّقة بشبكة تصنيفات الشكاوى).
                Expanded(
                  child: _VoteButton(
                    votes: complaint.votes,
                    voted: complaint.hasVoted,
                    enabled: canVote,
                    onTap: onVoteTap,
                  ),
                ),
                SizedBox(width: 8.w),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'complaint_open'.tr(),
                      style: context.texts.f12W400SecColor.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Directionality.of(context) == ui.TextDirection.rtl
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      size: 18.sp,
                      color: scheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _statusLabel(Complaint complaint) {
    return switch (complaint.status) {
      ComplaintStatus.underReview => 'complaint_status_under_review'.tr(),
      ComplaintStatus.inProgress => 'complaint_status_in_progress'.tr(),
      ComplaintStatus.closed => 'complaint_status_closed'.tr(),
      ComplaintStatus.unknown => 'complaint_status_under_review'.tr(),
    };
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: foreground),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.votes,
    required this.voted,
    required this.enabled,
    required this.onTap,
  });

  final int votes;
  final bool voted;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          height: 44.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: voted ? colors.brandSurface : scheme.surface,
            border: Border.all(color: voted ? scheme.primary : colors.border),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                size: 18.sp,
                color: voted ? scheme.primary : colors.textSecondary,
              ),
              SizedBox(width: 6.w),
              // ⚠️ العدّاد شارة منفصلة لا مدموج بالنص — «أعاني من هذه
              // الشكوى» جملة كاملة، ما بتنقرأ صح لو التصق فيها رقم
              // مباشرة («12 أعاني من هذه الشكوى» ركيك نحوياً).
              Flexible(
                child: Text(
                  'complaint_vote_label'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: voted ? scheme.primary : colors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: voted
                      ? scheme.primary.withValues(alpha: 0.15)
                      : colors.fieldDisabledBackground,
                  borderRadius: BorderRadius.circular(AppRadius.pill.r),
                ),
                child: Text(
                  '$votes',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: voted ? scheme.primary : colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
