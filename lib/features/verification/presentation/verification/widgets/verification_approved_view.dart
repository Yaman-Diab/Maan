// -------------------------
// Verification Approved View
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_button.dart';
import '../../../../../core/design_system/widgets/app_card.dart';
import 'verification_notice_box.dart';
import 'verification_status_hero.dart';

/// عرض «تم اعتماد طلب التوثيق»: علامة صح متحرّكة · وسم «موثّق» · قائمة
/// الخدمات اللي انفتحت · ملاحظة إن البيانات صارت مقفولة · زر الرئيسية.
class VerificationApprovedView extends StatelessWidget {
  const VerificationApprovedView({super.key, required this.onGoHome});

  final VoidCallback onGoHome;

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
                  icon: Icons.check_rounded,
                  color: colors.success,
                  backgroundColor: colors.successSurface,
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),

              Text(
                'verification_approved_title'.tr(),
                textAlign: TextAlign.center,
                style: context.texts.f16W500Black.copyWith(
                  color: colors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),

              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.successSurface,
                    borderRadius: BorderRadius.circular(AppRadius.pill.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 15.sp,
                        color: colors.success,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'verification_status_verified'.tr(),
                        style: context.texts.f12W400SecColor.copyWith(
                          color: colors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),

              Text(
                'verification_approved_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: context.texts.f14W400GreyColor,
              ),
              SizedBox(height: AppSpacing.md.h),

              AppCard(
                padding: EdgeInsets.all(AppSpacing.md.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'verification_unlocked_title'.tr(),
                      style: context.texts.f14W600Black,
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    _UnlockedItem(
                      icon: Icons.apartment_rounded,
                      label: 'verification_unlocked_services'.tr(),
                    ),
                    _UnlockedItem(
                      icon: Icons.campaign_rounded,
                      label: 'verification_unlocked_complaints'.tr(),
                    ),
                    _UnlockedItem(
                      icon: Icons.how_to_vote_rounded,
                      label: 'verification_unlocked_participation'.tr(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),

              VerificationInfoBox(message: 'verification_approved_note'.tr()),
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
            buttonText: 'verification_go_home'.tr(),
            buttonOnPressed: onGoHome,
            buttonColor: colors.success,
            buttonColorSide: colors.success,
          ),
        ),
      ],
    );
  }
}

class _UnlockedItem extends StatelessWidget {
  const _UnlockedItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: colors.brandSurface,
              borderRadius: BorderRadius.circular(AppRadius.sm.r),
            ),
            child: Icon(icon, size: 16.sp, color: context.scheme.primary),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(child: Text(label, style: context.texts.f14W400GreyColor)),
        ],
      ),
    );
  }
}
