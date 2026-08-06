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
                  label: 'authentication_index'.tr(),
                  icon: Icons.shield_rounded,
                  iconForeground: context.scheme.primary,
                  iconBackground: context.colors.brandSurface,
                  percentage: stats.authenticationIndex,
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
