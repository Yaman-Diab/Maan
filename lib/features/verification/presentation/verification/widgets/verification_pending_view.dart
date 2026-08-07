// -------------------------
// Verification Pending View
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/display_date_format.dart';
import '../../../../../core/design_system/widgets/app_button.dart';
import '../../../../../core/design_system/widgets/app_card.dart';
import '../../../domain/entities/verification_request.dart';
import 'verification_notice_box.dart';
import 'verification_status_hero.dart';

/// عرض «طلبك قيد المراجعة»: ساعة رملية متحرّكة · خط زمني بثلاث خطوات ·
/// ملخّص الطلب · ملاحظة · زر تصحيح الرقم الوطني.
class VerificationPendingView extends StatelessWidget {
  const VerificationPendingView({
    super.key,
    required this.request,
    required this.onEditNationalId,
  });

  final VerificationRequest request;
  final VoidCallback onEditNationalId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md.w,
              AppSpacing.xs.h,
              AppSpacing.md.w,
              AppSpacing.md.h,
            ),
            children: [
              Center(
                child: VerificationStatusHero(
                  icon: Icons.hourglass_top_rounded,
                  color: colors.noticeForeground,
                  backgroundColor: colors.noticeBackground,
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),

              Text(
                'verification_pending_title'.tr(),
                textAlign: TextAlign.center,
                style: context.texts.f16W500Black.copyWith(
                  color: colors.noticeForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                'verification_pending_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: context.texts.f14W400GreyColor,
              ),
              SizedBox(height: AppSpacing.md.h),

              const _StatusTimeline(),
              SizedBox(height: AppSpacing.sm.h),

              _RequestSummaryCard(request: request),
              SizedBox(height: AppSpacing.sm.h),

              VerificationInfoBox(
                message: 'verification_pending_note'.tr(),
              ),
            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md.w,
            AppSpacing.xs.h,
            AppSpacing.md.w,
            AppSpacing.md.h,
          ),
          // زر ثانوي: خلفية شفّافة وحدّ ونص بلون العلامة — التصميم
          // بيميّزه عن زر الإجراء الأساسي لأنه تصحيح اختياري لا خطوة
          // مطلوبة.
          child: AppButton(
            buttonText: 'verification_edit_national_id'.tr(),
            buttonOnPressed: onEditNationalId,
            buttonColor: Colors.transparent,
            buttonColorSide: context.scheme.primary,
            textColor: context.scheme.primary,
          ),
        ),
      ],
    );
  }
}

/// الخطوات الثلاث: تم الإرسال ← قيد المراجعة ← النتيجة.
///
/// ثابتة عن قصد: العرض ما بينعرض إلا لما تكون الحالة `pending`، يعني
/// الخطوة الأولى دائماً منتهية والثانية دائماً فعّالة والثالثة دائماً
/// منتظرة. أي حالة ثانية إلها عرضها الخاص.
class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;

    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md.w),
      child: Column(
        children: [
          _TimelineStep(
            icon: Icons.check_rounded,
            title: 'verification_step_submitted'.tr(),
            hint: 'verification_step_submitted_hint'.tr(),
            color: colors.success,
            hasLine: true,
          ),
          _TimelineStep(
            icon: Icons.hourglass_top_rounded,
            title: 'verification_step_review'.tr(),
            hint: 'verification_step_review_hint'.tr(),
            color: colors.noticeForeground,
            hasLine: true,
          ),
          _TimelineStep(
            icon: Icons.notifications_outlined,
            title: 'verification_step_result'.tr(),
            hint: 'verification_step_result_hint'.tr(),
            color: scheme.outline,
            hasLine: false,
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.hint,
    required this.color,
    required this.hasLine,
  });

  final IconData icon;
  final String title;
  final String hint;
  final Color color;
  final bool hasLine;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color),
                ),
                child: Icon(icon, size: 15.sp, color: color),
              ),
              if (hasLine)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: colors.divider,
                  ),
                ),
            ],
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: hasLine ? AppSpacing.sm.h : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.texts.f14W600Black),
                  SizedBox(height: 2.h),
                  Text(hint, style: context.texts.f12W400SecColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestSummaryCard extends StatelessWidget {
  const _RequestSummaryCard({required this.request});

  final VerificationRequest request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'verification_request_summary'.tr(),
                  style: context.texts.f14W600Black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: colors.noticeBackground,
                  borderRadius: BorderRadius.circular(AppRadius.pill.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13.sp,
                      color: colors.noticeForeground,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'verification_status_pending'.tr(),
                      style: context.texts.f12W400SecColor.copyWith(
                        color: colors.noticeForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
            child: Divider(height: 1, color: colors.divider),
          ),
          _SummaryRow(
            label: 'verification_row_request_id'.tr(),
            value: '#${request.id}',
          ),
          _SummaryRow(
            label: 'verification_row_national_id'.tr(),
            value: request.nationalId,
          ),
          _SummaryRow(
            label: 'verification_row_submitted_at'.tr(),
            value: request.createdAt.displayDate,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: context.texts.f12W400SecColor),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.texts.f14W600Black,
            ),
          ),
        ],
      ),
    );
  }
}
