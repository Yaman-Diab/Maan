// -------------------------
// Certificate Upload Sheet
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/media/certificate_file_picker_service.dart';
import '../../../domain/entities/certificate_status.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/usecases/attach_certificate_usecase.dart';
import '../../../domain/usecases/replace_certificate_usecase.dart';
import '../../shared/skill_style.dart';

/// إرفاق أول شهادة، أو استبدال شهادة قائمة (بما فيها المرفوضة).
/// بترجّع `true` بعد نجاح الإرسال.
Future<bool> showCertificateUploadSheet(
  BuildContext context, {
  required Skill skill,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CertificateUploadSheet(skill: skill),
  );

  return result ?? false;
}

enum _Stage { idle, picking, ready }

class _CertificateUploadSheet extends StatefulWidget {
  const _CertificateUploadSheet({required this.skill});

  final Skill skill;

  @override
  State<_CertificateUploadSheet> createState() =>
      _CertificateUploadSheetState();
}

class _CertificateUploadSheetState extends State<_CertificateUploadSheet> {
  _Stage _stage = _Stage.idle;
  PickedCertificateFile? _file;
  bool _submitting = false;

  Future<void> _pickFile() async {
    setState(() => _stage = _Stage.picking);

    final picker = sl<CertificateFilePickerService>();
    final file = await picker.pickFile();

    if (!mounted) return;

    if (file == null) {
      setState(() => _stage = _Stage.idle);
      return;
    }

    if (file.sizeInBytes > CertificateFilePickerService.maxSizeInBytes) {
      setState(() => _stage = _Stage.idle);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('certificate_file_too_large'.tr())),
        );
      return;
    }

    setState(() {
      _file = file;
      _stage = _Stage.ready;
    });
  }

  void _clearFile() {
    setState(() {
      _file = null;
      _stage = _Stage.idle;
    });
  }

  Future<void> _submit() async {
    final file = _file;
    if (file == null || _submitting) return;

    setState(() => _submitting = true);

    final certificate = widget.skill.certificate;

    final result = certificate == null
        ? await sl<AttachCertificateUseCase>()(
            AttachCertificateParams(skillId: widget.skill.id, file: file),
          )
        : await sl<ReplaceCertificateUseCase>()(
            ReplaceCertificateParams(certificateId: certificate.id, file: file),
          );

    if (!mounted) return;

    setState(() => _submitting = false);

    if (result.isOk) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.failureOrNull!.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;
    final certificate = widget.skill.certificate;
    final rejected = certificate?.status == CertificateStatus.rejected;
    final hasCurrentFile = certificate != null && !rejected;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22.r),
              topRight: Radius.circular(22.r),
            ),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        certificate == null
                            ? 'certificate_attach_sheet_title'.tr()
                            : 'certificate_replace_sheet_title'.tr(),
                        style: context.texts.f16W500Black.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                Text.rich(
                  TextSpan(
                    text: '${'certificate_for_skill_label'.tr()} ',
                    style: context.texts.f12W400SecColor,
                    children: [
                      TextSpan(
                        text: widget.skill.name,
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),

                if (rejected) ...[
                  Builder(
                    builder: (context) {
                      final reason = SkillStyle.rejectionReason(
                        certificate!.rejectionReason!,
                      );
                      final previousRejectedLabel =
                          'certificate_previous_rejected_label'.tr();
                      return Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: scheme.errorContainer,
                          border: Border.all(color: scheme.error),
                          borderRadius: BorderRadius.circular(AppRadius.md.r),
                        ),
                        child: Column(
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        previousRejectedLabel,
                                        style: TextStyle(
                                          fontSize: 10.5.sp,
                                          color: scheme.error.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        reason.label,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: scheme.error,
                                        ),
                                      ),
                                    ],
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
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                ],

                if (hasCurrentFile) ...[
                  Text(
                    'certificate_current_file_label'.tr(),
                    style: context.texts.f14W600Black.copyWith(fontSize: 13.sp),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: colors.pageBackground,
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(AppRadius.md.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            border: Border.all(color: colors.border),
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
                        Text(
                          'certificate_will_replace_label'.tr(),
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md.h),
                ],

                if (_stage == _Stage.idle)
                  InkWell(
                    onTap: _pickFile,
                    borderRadius: BorderRadius.circular(AppRadius.md.r),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 24.h,
                        horizontal: 12.w,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(AppRadius.md.r),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 28.sp,
                            color: scheme.primary,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'certificate_upload_cta'.tr(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: scheme.tertiary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'certificate_upload_hint'.tr(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: colors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_stage == _Stage.picking)
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 24.h,
                      horizontal: 14.w,
                    ),
                    decoration: BoxDecoration(
                      color: colors.brandSurface,
                      border: Border.all(color: scheme.primary),
                      borderRadius: BorderRadius.circular(AppRadius.md.r),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 28.sp,
                          color: scheme.primary,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'certificate_preparing'.tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: colors.brandSurface,
                      border: Border.all(color: scheme.primary),
                      borderRadius: BorderRadius.circular(AppRadius.md.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.picture_as_pdf_rounded,
                            size: 21.sp,
                            color: scheme.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _file?.fileName ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                              Text(
                                _formatSize(_file?.sizeInBytes ?? 0),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: colors.noticeForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _clearFile,
                          icon: Icon(
                            Icons.delete_rounded,
                            size: 20.sp,
                            color: scheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: AppSpacing.md.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: colors.infoBackground,
                    borderRadius: BorderRadius.circular(AppRadius.md.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18.sp,
                        color: colors.infoForeground,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'certificate_review_notice'.tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.6,
                            color: colors.infoForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: FilledButton.icon(
                    onPressed: _stage == _Stage.ready && !_submitting
                        ? _submit
                        : null,
                    icon: _submitting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text('certificate_submit_cta'.tr()),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md.r),
                      ),
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

  static String _formatSize(int bytes) {
    final mb = bytes / (1024 * 1024);

    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';

    final kb = bytes / 1024;

    return '${kb.toStringAsFixed(0)} KB';
  }
}
