// -------------------------
// Skill Detail Page
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_card.dart';
import '../../../domain/entities/certificate_status.dart';
import '../../../domain/entities/skill.dart';
import '../../shared/skill_style.dart';
import '../widgets/certificate_upload_sheet.dart';
import '../widgets/skill_delete_sheet.dart';
import '../widgets/skill_form_sheet.dart';

/// تفاصيل مهارة — الكيان بيوصل جاهزاً عبر الـ constructor (نفس منطق
/// `ComplaintDetailPage`)، والتعديل/الحذف/الشهادة محلية بحالة الشاشة.
/// `Navigator.pop(true)` لو صار أي تغيير حتى `SkillsPage` تعيد التحميل،
/// `pop(false)`/`pop()` لو ما تغيّر شي.
class SkillDetailPage extends StatefulWidget {
  const SkillDetailPage({super.key, required this.skill});

  final Skill skill;

  @override
  State<SkillDetailPage> createState() => _SkillDetailPageState();
}

class _SkillDetailPageState extends State<SkillDetailPage> {
  late final Skill _skill = widget.skill;

  Future<void> _editSkill() async {
    final saved = await showSkillFormSheet(context, skill: _skill);

    if (saved && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('skills_toast_updated'.tr())));
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _certificateAction() async {
    final submitted = await showCertificateUploadSheet(context, skill: _skill);

    if (submitted && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('skills_toast_certificate_submitted'.tr())),
        );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteSkill() async {
    final deleted = await confirmAndDeleteSkill(context, skillId: _skill.id);

    if (deleted && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;
    final typeStyle = SkillStyle.type(context, _skill.type);
    final statusStyle = SkillStyle.status(context, _skill.certificate?.status);
    final certificate = _skill.certificate;
    final rejected = certificate?.status == CertificateStatus.rejected;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'skills_detail_title'.tr(),
          style: context.texts.f16W500Black.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: typeStyle.background,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      typeStyle.icon,
                      size: 28.sp,
                      color: typeStyle.foreground,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _skill.name,
                          style: context.texts.f16W500Black.copyWith(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w600,
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
                              label: typeStyle.label,
                              style: typeStyle,
                            ),
                            _Chip(
                              icon: statusStyle.icon,
                              label: statusStyle.label,
                              style: statusStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md.h),
              AppCard(
                padding: EdgeInsets.all(AppSpacing.md.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      label: 'skills_type_label'.tr(),
                      value: typeStyle.label,
                    ),
                    if (_skill.createdAt != null)
                      _InfoRow(
                        label: 'skills_date_added_label'.tr(),
                        value: _skill.createdAt!
                            .toLocal()
                            .toString()
                            .split(' ')
                            .first,
                      ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              Text(
                'skills_certificate_file_section'.tr(),
                style: context.texts.f14W600Black,
              ),
              SizedBox(height: AppSpacing.sm.h),
              if (certificate == null)
                AppCard(
                  padding: EdgeInsets.all(AppSpacing.md.w),
                  child: Column(
                    children: [
                      Icon(
                        Icons.upload_file_rounded,
                        size: 36.sp,
                        color: colors.textHint,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'skills_no_certificate_title'.tr(),
                        style: context.texts.f14W600Black.copyWith(
                          fontSize: 13.5.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'skills_no_certificate_body'.tr(),
                        textAlign: TextAlign.center,
                        style: context.texts.f12W400SecColor.copyWith(
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: FilledButton.icon(
                          onPressed: _certificateAction,
                          icon: Icon(Icons.upload_file_rounded, size: 19.sp),
                          label: Text('skills_attach_cta'.tr()),
                        ),
                      ),
                    ],
                  ),
                )
              else if (rejected)
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    border: Border.all(color: scheme.error),
                    borderRadius: BorderRadius.circular(AppRadius.md.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          final reason = SkillStyle.rejectionReason(
                            certificate.rejectionReason!,
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    reason.icon,
                                    size: 18.sp,
                                    color: scheme.error,
                                  ),
                                  SizedBox(width: 7.w),
                                  Expanded(
                                    child: Text(
                                      reason.label,
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w600,
                                        color: scheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 7.h),
                              Text(
                                reason.text,
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  height: 1.65,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: FilledButton.icon(
                          onPressed: _certificateAction,
                          icon: Icon(Icons.cloud_upload_rounded, size: 19.sp),
                          label: Text('skills_reupload_cta'.tr()),
                          style: FilledButton.styleFrom(
                            backgroundColor: scheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                AppCard(
                  padding: EdgeInsets.all(AppSpacing.md.w),
                  child: Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: colors.fieldDisabledBackground,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.description_rounded,
                          size: 21.sp,
                          color: colors.textHint,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          certificate.fileName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      OutlinedButton.icon(
                        onPressed: _certificateAction,
                        icon: Icon(Icons.swap_horiz_rounded, size: 17.sp),
                        label: Text('skills_replace_cta'.tr()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.primary,
                          side: BorderSide(color: colors.border),
                        ),
                      ),
                    ],
                  ),
                ),
              if (certificate?.status == CertificateStatus.pending) ...[
                SizedBox(height: AppSpacing.sm.h),
                Container(
                  padding: EdgeInsets.all(11.w),
                  decoration: BoxDecoration(
                    color: colors.infoBackground,
                    borderRadius: BorderRadius.circular(AppRadius.md.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 17.sp,
                        color: colors.infoForeground,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'skills_pending_notice'.tr(),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            height: 1.6,
                            color: colors.infoForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.lg.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _editSkill,
                      icon: Icon(Icons.edit_outlined, size: 18.sp),
                      label: Text('skills_edit_cta'.tr()),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(0, 48.h),
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.border),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _deleteSkill,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 18.sp,
                        color: scheme.error,
                      ),
                      label: Text(
                        'delete'.tr(),
                        style: TextStyle(color: scheme.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(0, 48.h),
                        side: BorderSide(color: scheme.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.style});

  final IconData icon;
  final String label;
  final SkillStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: style.foreground),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: style.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.texts.f12W400SecColor)),
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
