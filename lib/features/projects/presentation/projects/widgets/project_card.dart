// -------------------------
// Project Card
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_progress_bar.dart';
import '../../../../../core/design_system/widgets/place_name_text.dart';
import '../../../../../core/format/amount_formatter.dart';
import '../../../domain/entities/municipal_project.dart';
import '../../../domain/entities/project_donation_stats.dart';
import '../../../domain/entities/project_reaction.dart';
import 'donate_dialog.dart';
import 'volunteer_dialog.dart';

/// بطاقة مشروع بلدي — مشتركة بين شريط الرئيسية وتاب المشاريع، فأي
/// تعديل على الشكل بينعكس بالمكانين.
///
/// الحوارات (تطوّع/تبرّع) بتتفتح من هون مباشرة بدل ما ترجع callback
/// للشاشة: هي سلوك البطاقة نفسها، وما بتحتاج أي حالة من الشاشة الحاضنة
/// غير `canParticipate`.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.canParticipate,
    this.onReactionTap,
    this.voting = false,
  });

  final MunicipalProject project;

  /// الحساب موثّق — التطوّع والرأي محجوزان للموثّقين.
  final bool canParticipate;

  /// اختياري — الشاشة اللي بتمرّره هي المسؤولة عن التعامل معه (نفس
  /// نمط `ProjectsCubit.vote`: `value: true` = أحبذ، `false` = لا
  /// أحبذ). الضغط على الخيار المفعّل حالياً بيسحب الصوت، والضغط على
  /// المعاكس بيبدّله — التبديل والسحب مسؤولية المستلم، البطاقة بس
  /// بتبلّغ أي زر انضغط.
  final void Function(MunicipalProject project, bool value)? onReactionTap;

  /// طلب تصويت شغّال هلأ لهالمشروع تحديداً — الزرّين بيتعطّلوا
  /// وبيبيّنوا مؤشّر تحميل بدل الأيقونة.
  final bool voting;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        boxShadow: AppShadows.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: colors.brandSurface,
                  borderRadius: BorderRadius.circular(AppRadius.pill.r),
                ),
                child: Icon(
                  Icons.apartment_rounded,
                  size: 23.sp,
                  color: scheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.f14W600Black.copyWith(
                        fontSize: 14.5.sp,
                        height: 1.35,
                      ),
                    ),
                    if (project.description != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        project.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.f12W400SecColor.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (project.hasLocation) ...[
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14.sp,
                            color: colors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: PlaceNameText(
                              latitude: project.latitude!,
                              longitude: project.longitude!,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (onReactionTap != null) ...[
            SizedBox(height: 11.h),
            Container(height: 1, color: colors.divider),
            SizedBox(height: 11.h),
            Row(
              children: [
                _ReactionButton(
                  icon: project.myReaction == ProjectReaction.favor
                      ? Icons.thumb_up_alt_rounded
                      : Icons.thumb_up_off_alt_rounded,
                  // ⚠️ عدّاد مرجَّح (بمؤشّر مواطنة الناخب) لا عدّ رؤوس
                  // بسيط — راجع `MunicipalProject.weightedYesVotes`.
                  count: project.weightedYesVotes.round(),
                  label: 'project_favor_label'.tr(),
                  active: project.myReaction == ProjectReaction.favor,
                  activeColor: scheme.primary,
                  activeBackground: colors.brandSurface,
                  enabled: canParticipate && !voting,
                  loading: voting,
                  onTap: () => onReactionTap!(project, true),
                ),
                SizedBox(width: 8.w),
                _ReactionButton(
                  icon: project.myReaction == ProjectReaction.oppose
                      ? Icons.thumb_down_alt_rounded
                      : Icons.thumb_down_off_alt_rounded,
                  count: project.weightedOpposeVotes.round(),
                  label: 'project_oppose_label'.tr(),
                  active: project.myReaction == ProjectReaction.oppose,
                  activeColor: scheme.error,
                  activeBackground: scheme.errorContainer,
                  enabled: canParticipate && !voting,
                  loading: voting,
                  onTap: () => onReactionTap!(project, false),
                ),
              ],
            ),
          ],

          if (project.hasActions) ...[
            SizedBox(height: 12.h),
            // شريط التبرعات فوق الأزرار: بيعطي السياق («وين وصلنا»)
            // قبل الإجراء نفسه، لا بعده.
            if (project.donationStats != null) ...[
              _DonationProgress(stats: project.donationStats!),
              SizedBox(height: 12.h),
            ],
            if (project.requiresVolunteers) ...[
              Text(
                'project_volunteers_needed'.tr(
                  namedArgs: {'count': '${project.volunteersNeeded}'},
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
            ],
            Row(
              children: [
                if (project.requiresVolunteers)
                  Expanded(
                    child: _VolunteerButton(
                      project: project,
                      enabled: canParticipate,
                    ),
                  ),
                if (project.requiresVolunteers && project.requiresDonations)
                  SizedBox(width: 8.w),
                if (project.requiresDonations)
                  Expanded(child: _DonateButton(project: project)),
              ],
            ),
            if (project.requiresVolunteers && !canParticipate) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.lock_rounded, size: 14.sp, color: colors.textHint),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      'project_volunteer_locked'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1.35,
                        color: colors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// شريط تقدّم التبرعات — نسبة + مبلغ مجموع/هدف + عدد المتبرعين.
///
/// ⚠️ **حالتان مختلفتان جوهرياً**:
/// * في هدف (`hasTarget`) → شريط تقدّم بنسبة، «X من Y»، والمتبقّي.
/// * بلا هدف (المشروع بلا ميزانية محدّدة) → **بلا شريط ولا نسبة**، بس
///   المبلغ المجموع. شريط تقدّم بلا هدف بيرسم تقدّماً نحو لا شي، و
///   `donationPercentage` بترجع `0` بهالحالة فكان رح يبان فاضياً
///   دائماً وكأن ما حدا تبرّع.
class _DonationProgress extends StatelessWidget {
  const _DonationProgress({required this.stats});

  final ProjectDonationStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currency = 'currency_syp'.tr();

    // اكتمل الهدف → أخضر بدل الكهرماني: إشارة إنجاز، والكهرماني
    // بيضل معناه «لسه بدنا».
    final accent = stats.isFunded ? colors.success : colors.noticeForeground;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: colors.noticeBackground,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.savings_rounded, size: 15.sp, color: accent),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'project_donations_title'.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (stats.hasTarget)
                Text(
                  stats.isFunded
                      ? 'project_donations_funded'.tr()
                      : '${stats.donationPercentage}%',
                  style: TextStyle(
                    fontSize: stats.isFunded ? 11.sp : 13.sp,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
            ],
          ),

          if (stats.hasTarget) ...[
            SizedBox(height: 9.h),
            AppProgressBar(percentage: stats.donationPercentage, color: accent),
          ],

          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  stats.hasTarget
                      ? 'project_donations_raised'.tr(
                          namedArgs: {
                            'raised': AmountFormatter.format(
                              stats.totalDonated,
                            ),
                            'target': AmountFormatter.format(
                              stats.donationTarget!,
                            ),
                            'currency': currency,
                          },
                        )
                      : 'project_donations_raised_no_target'.tr(
                          namedArgs: {
                            'raised': AmountFormatter.format(
                              stats.totalDonated,
                            ),
                            'currency': currency,
                          },
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'project_donors_count'.tr(
                  namedArgs: {'count': '${stats.numberOfDonors}'},
                ),
                style: TextStyle(fontSize: 11.sp, color: colors.textSecondary),
              ),
            ],
          ),

          // المتبقّي سطر ثانوي — بيظهر بس لو في هدف وما اكتمل، لأن
          // «بقي 0» بعد الاكتمال حشو، و«بقي ...» بلا هدف بلا معنى.
          if (stats.hasTarget &&
              !stats.isFunded &&
              stats.remainingAmount != null) ...[
            SizedBox(height: 3.h),
            Text(
              'project_donations_remaining'.tr(
                namedArgs: {
                  'amount': AmountFormatter.format(stats.remainingAmount!),
                  'currency': currency,
                },
              ),
              style: TextStyle(fontSize: 11.sp, color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.icon,
    required this.count,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.activeBackground,
    required this.enabled,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final int count;
  final String label;
  final bool active;
  final Color activeColor;
  final Color activeBackground;
  final bool enabled;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;
    final foreground = active ? activeColor : colors.textSecondary;

    return Expanded(
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: InkWell(
          // ⚠️ `null` لا مجرّد شفافية — بلاها الزر بيضل قابل للضغط
          // بصرياً «معطّل» بس فعلياً شغّال، وبيضاعف طلب التصويت لو
          // انضغط أكتر من مرة أثناء التحميل.
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadius.pill.r),
          child: Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: active ? activeBackground : scheme.surface,
              border: Border.all(color: active ? activeColor : colors.border),
              borderRadius: BorderRadius.circular(AppRadius.pill.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
                else
                  Icon(icon, size: 16.sp, color: foreground),
                SizedBox(width: 5.w),
                Flexible(
                  child: Text(
                    '$count $label',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VolunteerButton extends StatelessWidget {
  const _VolunteerButton({required this.project, required this.enabled});

  final MunicipalProject project;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: FilledButton.icon(
        onPressed: enabled
            ? () => showVolunteerDialog(context, project: project)
            : null,
        icon: Icon(
          enabled ? Icons.volunteer_activism_rounded : Icons.lock_rounded,
          size: 17.sp,
        ),
        label: Text('project_volunteer_cta'.tr()),
        style: FilledButton.styleFrom(
          textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
          ),
        ),
      ),
    );
  }
}

class _DonateButton extends StatelessWidget {
  const _DonateButton({required this.project});

  final MunicipalProject project;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 38.h,
      child: OutlinedButton.icon(
        // بلا شرط توثيق — الحوار توجيه للبلدية لا عملية دفع.
        onPressed: () => showDonateDialog(context, project: project),
        icon: Icon(Icons.savings_rounded, size: 17.sp),
        label: Text('project_donate_cta'.tr()),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.noticeForeground,
          backgroundColor: colors.noticeBackground,
          side: BorderSide(color: colors.noticeForeground),
          textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
          ),
        ),
      ),
    );
  }
}
