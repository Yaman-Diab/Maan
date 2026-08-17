// -------------------------
// Skill Card
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../domain/entities/certificate_status.dart';
import '../../../domain/entities/skill.dart';
import '../../shared/skill_style.dart';

class SkillCard extends StatelessWidget {
  const SkillCard({
    super.key,
    required this.skill,
    required this.onOpen,
    required this.onCertificateAction,
  });

  final Skill skill;
  final VoidCallback onOpen;
  final VoidCallback onCertificateAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;
    final typeStyle = SkillStyle.type(context, skill.type);
    final statusStyle = SkillStyle.status(context, skill.certificate?.status);
    final certificate = skill.certificate;
    final rejected = certificate?.status == CertificateStatus.rejected;

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16.r),
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
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: typeStyle.background,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    typeStyle.icon,
                    size: 24.sp,
                    color: typeStyle.foreground,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.name,
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
                            label: typeStyle.label,
                            style: typeStyle,
                          ),
                          _Chip(
                            icon: statusStyle.icon,
                            label: statusStyle.label,
                            style: statusStyle,
                            pulse:
                                certificate?.status ==
                                CertificateStatus.pending,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  size: 20.sp,
                  color: scheme.primary,
                ),
              ],
            ),
            if (certificate != null && !rejected) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.only(top: 12.h),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.divider)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: colors.fieldDisabledBackground,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        size: 19.sp,
                        color: colors.textHint,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        certificate.fileName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    OutlinedButton.icon(
                      onPressed: onCertificateAction,
                      icon: Icon(Icons.swap_horiz_rounded, size: 17.sp),
                      label: Text('skills_replace_cta'.tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.primary,
                        side: BorderSide(color: colors.border),
                        padding: EdgeInsets.symmetric(horizontal: 13.w),
                        minimumSize: Size(0, 44.h),
                        textStyle: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (certificate == null) ...[
              SizedBox(height: 12.h),
              InkWell(
                onTap: onCertificateAction,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: 48.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: colors.brandSurface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: scheme.primary,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.upload_file_rounded,
                        size: 21.sp,
                        color: scheme.primary,
                      ),
                      SizedBox(width: 9.w),
                      Expanded(
                        child: Text(
                          'skills_add_certificate_cta'.tr(),
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                      Text(
                        'skills_optional_mark'.tr(),
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: scheme.primary.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (rejected) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(11.w),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  border: Border.all(color: scheme.error),
                  borderRadius: BorderRadius.circular(12.r),
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
                                  size: 17.sp,
                                  color: scheme.error,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    reason.label,
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
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
                                fontSize: 12.sp,
                                height: 1.65,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 11.h),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onCertificateAction,
                        icon: Icon(Icons.cloud_upload_rounded, size: 19.sp),
                        label: Text('skills_reupload_cta'.tr()),
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.error,
                          minimumSize: Size(0, 44.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.style,
    this.pulse = false,
  });

  final IconData icon;
  final String label;
  final SkillStyle style;
  final bool pulse;

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
          if (pulse) ...[
            SizedBox(width: 5.w),
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: style.foreground,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
