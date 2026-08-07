// -------------------------
// Verification Profile Card
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/display_date_format.dart';
import '../../../../../core/design_system/widgets/app_card.dart';
import '../../../../auth/domain/entities/auth_user.dart';

/// بطاقة «البيانات الشخصية» أعلى نموذج التوثيق — **عرض فقط** + زر
/// «تعديل» بينقل لشاشة تعديل الهوية.
///
/// ليش عرض فقط وما فيها حقول؟ لأن الشرط الثالث بتنبيه التوثيق هو
/// «يجب أن تطابق المعلومات هويتك الرسمية» — فالمستخدم لازم **يشوف** شو
/// رح ينبعت مع الطلب قبل ما يرسل. التعديل بيصير بشاشته المخصّصة بدل
/// نسخة تانية من نفس النموذج هون.
///
/// ⚠️ الرقم الوطني **مش من ضمنها** عن قصد — إله حقله الخاص بنفس
/// الشاشة، وشاشة التوثيق هي مالكته الوحيدة.
class VerificationProfileCard extends StatelessWidget {
  const VerificationProfileCard({
    super.key,
    required this.user,
    required this.onEdit,
  });

  final AuthUser user;
  final VoidCallback onEdit;

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
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: colors.infoBackground,
                  borderRadius: BorderRadius.circular(AppRadius.sm.r),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 18.sp,
                  color: colors.infoForeground,
                ),
              ),
              SizedBox(width: AppSpacing.xs.w),
              Expanded(
                child: Text(
                  'verification_profile_section'.tr(),
                  style: context.texts.f14W600Black,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // العنصر التفاعلي بياخد حجمه كامل والتسمية هي اللي بتنقطع
              // — نفس قاعدة `_SettingsControlRow` بشاشة الإعدادات.
              GestureDetector(
                onTap: onEdit,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs.w,
                    vertical: 4.h,
                  ),
                  child: Text(
                    'edit'.tr(),
                    style: context.texts.f12W400SecColor.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.scheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),

          _InfoRow(label: 'first_name'.tr(), value: user.firstName),
          _InfoRow(label: 'last_name'.tr(), value: user.lastName),
          _InfoRow(
            label: 'date_of_birth'.tr(),
            value: user.birthDate.displayDate,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.xs.h),
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
