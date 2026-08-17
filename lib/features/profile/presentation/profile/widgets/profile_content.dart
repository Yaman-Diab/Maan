// -------------------------
// Profile Content
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/session/account_status.dart';
import '../../../domain/entities/citizen_profile.dart';
import 'activity_card.dart';
import 'identity_info_card.dart';
import 'profile_header.dart';
import '../../../../../core/design_system/widgets/app_section_header.dart';
import 'stat_index_card.dart';

/// جسم الشاشة لما تكون البيانات جاهزة.
class ProfileContent extends StatelessWidget {
  const ProfileContent({
    super.key,
    required this.profile,
    this.localAvatarPath,
    this.avatarRemoved = false,
    this.isUploadingAvatar = false,
    this.isRemovingAvatar = false,
    this.onAddPhotoTap,
    this.onEditTap,
    this.onVerifyTap,
    required this.onCertificatesTap,
  });

  final CitizenProfile profile;

  final String? localAvatarPath;
  final bool avatarRemoved;
  final bool isUploadingAvatar;
  final bool isRemovingAvatar;
  final VoidCallback? onAddPhotoTap;

  /// شاشة تعديل الهوية لسه ما انبنت، فبتوصل `null` واليوم ما بينعرض
  /// زر «تعديل» أصلاً. زر بيضغط ولا بيصير شي أسوأ من زر غير موجود.
  final VoidCallback? onEditTap;

  /// مدخل شاشة توثيق الهوية. بيظهر للحسابات **غير الموثّقة** بس —
  /// الموثّق خلّص العملية، وعرض دعوة للتوثيق عليه بيربك.
  final VoidCallback? onVerifyTap;

  /// مدخل شاشة «الشهادات والمهارات». **إلزامي لا اختياري** بعكس
  /// `onEditTap`/`onVerifyTap`: هدول شرطيين بحالة الحساب، وهاد بانر
  /// ثابت بالتصميم بيظهر دائماً — فمصدره (`ProfilePage`) لازم يمرّره
  /// دايماً، مش يترك حالة «موجود بس بلا فعل».
  final VoidCallback onCertificatesTap;

  @override
  Widget build(BuildContext context) {
    final user = profile.user;
    final stats = profile.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileHeader(
          user: user,
          localAvatarPath: localAvatarPath,
          avatarRemoved: avatarRemoved,
          // عملية وحدة بس تشتغل بلحظة معيّنة (رفع أو إزالة)، فبكفي
          // مؤشّر تقدّم واحد يعكس الاثنين.
          isUploadingAvatar: isUploadingAvatar || isRemovingAvatar,
          onAddPhotoTap: onAddPhotoTap,
        ),

        AppSectionHeader(
          title: 'profile_identity_section'.tr(),
          trailing: _identityAction(context),
        ),

        SizedBox(height: 12.h),

        IdentityInfoCard(user: user),

        if (user.accountStatus != AccountStatus.verified &&
            onVerifyTap != null) ...[
          SizedBox(height: 12.h),
          _VerifyAccountBanner(onTap: onVerifyTap!),
        ],

        SizedBox(height: 12.h),

        _CertificatesBanner(onTap: onCertificatesTap),

        SizedBox(height: 22.h),

        AppSectionHeader(title: 'profile_statistics_section'.tr()),

        SizedBox(height: 12.h),

        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatIndexCard(
                  label: 'citizenship_index'.tr(),
                  icon: Icons.workspace_premium_rounded,
                  iconForeground: context.scheme.tertiary,
                  iconBackground: context.colors.noticeBackground,
                  percentage: stats.citizenshipIndex,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: StatIndexCard(
                  label: 'credibility_index'.tr(),
                  icon: Icons.shield_rounded,
                  iconForeground: context.scheme.primary,
                  iconBackground: context.colors.brandSurface,
                  percentage: stats.credibilityIndex,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 22.h),

        AppSectionHeader(title: 'profile_activity_section'.tr()),

        SizedBox(height: 12.h),

        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ActivityCard(
                  title: 'activity_volunteering'.tr(),
                  countLabel: _count(
                    stats.volunteeringCount,
                    (count) => 'activity_participations_count'.tr(
                      namedArgs: {'count': count},
                    ),
                  ),
                  icon: Icons.groups_rounded,
                  iconForeground: context.scheme.primary,
                  iconBackground: context.colors.brandSurface,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ActivityCard(
                  title: 'activity_contributions'.tr(),
                  countLabel: _count(
                    stats.contributionsCount,
                    (count) => 'activity_donations_count'.tr(
                      namedArgs: {'count': count},
                    ),
                  ),
                  icon: Icons.volunteer_activism_rounded,
                  iconForeground: context.colors.noticeForeground,
                  iconBackground: context.colors.noticeBackground,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ActivityCard(
                  title: 'activity_licenses'.tr(),
                  countLabel: _count(
                    stats.licensesCount,
                    (count) => 'activity_licenses_count'.tr(
                      namedArgs: {'count': count},
                    ),
                  ),
                  icon: Icons.badge_rounded,
                  iconForeground: context.colors.infoForeground,
                  iconBackground: context.colors.infoBackground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// الموثّق ما بيقدر يعدّل هويته — انعتمدت رسمياً، فالتعديل بيمرّ
  /// بالبلدية لا بالتطبيق. الزائر لسه يقدر يصحّح بياناته.
  //
  // ملاحظة: البانر تحت هو المدخل الوحيد لشاشة التوثيق حالياً.
  Widget? _identityAction(BuildContext context) {
    final texts = context.texts;

    if (profile.user.accountStatus == AccountStatus.verified) {
      return Text(
        'profile_cannot_edit'.tr(),
        style: texts.f12W400SecColor.copyWith(color: context.scheme.error),
      );
    }

    if (onEditTap == null) return null;

    return GestureDetector(
      onTap: onEditTap,
      child: Text(
        'edit'.tr(),
        style: texts.f12W400SecColor.copyWith(
          fontWeight: FontWeight.w500,
          color: context.scheme.primary,
        ),
      ),
    );
  }

  /// بترجّع `null` لو العدّاد ما وصل، فالبطاقة بتعرض «—».
  ///
  /// الترجمة بتنمرّر كدالة لا كاسم مفتاح: حارس الترجمة بيمسح `lib/` عن
  /// المفتاح **حرفياً** قبل نقطة الترجمة، فمفتاح داخل متغيّر بينحسب «غير
  /// مستخدم» وبيوقّع الاختبار — راجع
  /// `test/localization/localization_test.dart`.
  static String? _count(int? value, String Function(String count) translate) {
    if (value == null) return null;

    return translate('$value');
  }
}

/// دعوة لتوثيق الحساب — بتظهر للحسابات غير الموثّقة بس.
///
/// بطاقة قابلة للنقر لا زر: التوثيق خطوة اختيارية بالوقت الحالي (الحساب
/// شغّال بلاها، بس بصلاحيات أقل)، فبتاخد وزن «دعوة» لا «إجراء مطلوب».
class _VerifyAccountBanner extends StatelessWidget {
  const _VerifyAccountBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: colors.brandSurface,
          border: Border.all(color: scheme.primary),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 22.sp,
              color: scheme.primary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'profile_verify_cta_title'.tr(),
                    style: context.texts.f14W600Black,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'profile_verify_cta_subtitle'.tr(),
                    style: context.texts.f12W400SecColor,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// مدخل «الشهادات والمهارات» — بانر مصمَت بلون الهوية، بعكس بانر
/// التوثيق (خلفية فاتحة وحدود). دايماً ظاهر، مش شرطي بحالة الحساب.
class _CertificatesBanner extends StatelessWidget {
  const _CertificatesBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: scheme.onPrimary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.card_membership_rounded,
                size: 22.sp,
                color: scheme.onPrimary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'certificates_skills_title'.tr(),
                    style: context.texts.f14W600Black.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'certificates_skills_subtitle'.tr(),
                    style: context.texts.f12W400SecColor.copyWith(
                      color: scheme.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: scheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
