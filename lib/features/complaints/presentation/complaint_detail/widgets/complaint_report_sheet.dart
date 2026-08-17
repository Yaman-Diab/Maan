// -------------------------
// Complaint Report Sheet
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/custom_text_form_field.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../domain/entities/complaint_report_reason.dart';
import '../../../domain/usecases/report_complaint_usecase.dart';

Future<bool> showComplaintReportSheet(
  BuildContext context, {
  required int complaintId,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ReportSheet(complaintId: complaintId),
  );

  return result ?? false;
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.complaintId});

  final int complaintId;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _descController = TextEditingController();
  ComplaintReportReason? _reason;
  bool _submitting = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _reason != null && _descController.text.trim().isNotEmpty && !_submitting;

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() => _submitting = true);

    final result = await sl<ReportComplaintUseCase>()(
      ReportComplaintParams(
        complaintId: widget.complaintId,
        reason: _reason!,
        description: _descController.text.trim(),
      ),
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

  static String _label(ComplaintReportReason reason) {
    return switch (reason) {
      ComplaintReportReason.violent => 'report_violent'.tr(),
      ComplaintReportReason.inappropriate => 'report_inappropriate'.tr(),
      ComplaintReportReason.misleading => 'report_misleading'.tr(),
      ComplaintReportReason.abusive => 'report_abusive'.tr(),
      ComplaintReportReason.irrelevant => 'report_irrelevant'.tr(),
      ComplaintReportReason.other => 'report_other'.tr(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;

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
              Text(
                'report_sheet_title'.tr(),
                style: context.texts.f16W500Black.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'report_sheet_subtitle'.tr(),
                style: context.texts.f12W400SecColor,
              ),
              SizedBox(height: 4.h),
              for (final reason in ComplaintReportReason.values)
                InkWell(
                  onTap: () => setState(() => _reason = reason),
                  child: SizedBox(
                    height: 48.h,
                    child: Row(
                      children: [
                        Icon(
                          reason == _reason
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 22.sp,
                          color: reason == _reason
                              ? scheme.primary
                              : colors.border,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          _label(reason),
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: reason == _reason
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: reason == _reason
                                ? scheme.primary
                                : colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: AppSpacing.sm.h),
              Row(
                children: [
                  Text(
                    'report_desc_label'.tr(),
                    style: context.texts.f14W600Black,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'required_mark'.tr(),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: scheme.error,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              CustomTextFormField(
                controller: _descController,
                validationMessage: (_) => null,
                keyBoardType: TextInputType.multiline,
                hintText: 'report_desc_hint'.tr(),
                onChanged: (_) => setState(() {}),
                maxLines: 3,
                minLines: 3,
              ),
              SizedBox(height: AppSpacing.md.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    disabledBackgroundColor: scheme.error.withValues(
                      alpha: 0.45,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md.r),
                    ),
                  ),
                  child: _submitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onError,
                          ),
                        )
                      : Text(
                          'report_submit'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: scheme.onError,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 4.h),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('cancel'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
