// -------------------------
// Verification Rejected View
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_button.dart';
import '../../../domain/entities/verification_request.dart';
import 'verification_notice_box.dart';
import 'verification_status_hero.dart';

/// عرض «تم رفض طلب التوثيق»: أيقونة رفض · بطاقة السبب · شروط الصورة
/// من جديد · زر إعادة الإرسال.
class VerificationRejectedView extends StatelessWidget {
  const VerificationRejectedView({
    super.key,
    required this.request,
    required this.onResubmit,
  });

  final VerificationRequest request;
  final VoidCallback onResubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

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
                  icon: Icons.close_rounded,
                  color: scheme.error,
                  backgroundColor: scheme.errorContainer,
                  // حالة نهائية لا انتظار — الحلقات المتمدّدة بتوحي
                  // بعملية شغّالة، وهون ما في شي بيصير.
                  showRings: false,
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),

              Text(
                'verification_rejected_title'.tr(),
                textAlign: TextAlign.center,
                style: context.texts.f16W500Black.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                'verification_rejected_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: context.texts.f14W400GreyColor,
              ),
              SizedBox(height: AppSpacing.md.h),

              _RejectionReasonCard(request: request),
              SizedBox(height: AppSpacing.sm.h),

              VerificationRulesBox(title: 'verification_fix_title'.tr()),
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
          child: AppButton(
            buttonText: 'verification_edit_resubmit'.tr(),
            buttonOnPressed: onResubmit,
            buttonColor: scheme.error,
            buttonColorSide: scheme.error,
            textColor: scheme.onError,
          ),
        ),
      ],
    );
  }
}

/// بطاقة سبب الرفض.
///
/// ⚠️ الحقول **مخمَّنة** (راجع `VerificationRequest.rejectionReason`):
/// لو ما وصل سبب، بتنعرض رسالة عامة بدل ما تظهر البطاقة فاضية أو تختفي
/// كلياً — المستخدم لازم يفهم إنه انرفض حتى لو ما وصل التفصيل.
class _RejectionReasonCard extends StatelessWidget {
  const _RejectionReasonCard({required this.request});

  final VerificationRequest request;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final description = request.rejectionDescription;
    final reason = request.rejectionReason;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        border: Border.all(color: scheme.error),
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline_rounded, size: 18.sp, color: scheme.error),
              SizedBox(width: AppSpacing.xs.w),
              Expanded(
                child: Text(
                  'verification_reason_title'.tr(),
                  style: context.texts.f14W600Black.copyWith(
                    color: scheme.error,
                  ),
                ),
              ),
              if (reason != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xs.r),
                  ),
                  // الوسم بيعرض رمز السبب كما وصل من الباك اند
                  // (`blurry_images`) بلا ترجمة: القيم المحتملة غير
                  // معروفة كاملة، فترجمة جزئية بتخفي الباقي. الشرح
                  // المترجَم تحت هو اللي بيوصل المعنى.
                  child: Text(
                    reason,
                    style: context.texts.f12W400SecColor.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            description ?? 'verification_reason_fallback'.tr(),
            style: context.texts.f14W400Primary.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
