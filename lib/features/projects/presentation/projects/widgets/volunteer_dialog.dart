// -------------------------
// Volunteer Dialog
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/custom_text_form_field.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../domain/entities/municipal_project.dart';
import '../../../domain/usecases/volunteer_for_project_usecase.dart';
import 'volunteer_rejection_message.dart';

/// تسجيل تطوّع برقم هاتف — الرقم بينضاف لمجموعة واتساب التنسيق.
///
/// بتنادي `VolunteerForProjectUseCase` مباشرة عبر `sl<>()` بدل ما تمرّ
/// بـCubit، نفس نمط `ComplaintReportSheet`/`showSkillFormSheet`:
/// الحالة (إرسال/خطأ/نجاح) محلية بالحوار نفسه.
Future<void> showVolunteerDialog(
  BuildContext context, {
  required MunicipalProject project,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _VolunteerDialog(project: project),
  );
}

class _VolunteerDialog extends StatefulWidget {
  const _VolunteerDialog({required this.project});

  final MunicipalProject project;

  @override
  State<_VolunteerDialog> createState() => _VolunteerDialogState();
}

class _VolunteerDialogState extends State<_VolunteerDialog> {
  final _phoneController = TextEditingController();

  bool _submitting = false;
  bool _submitted = false;
  String? _errorMessage;

  /// أقصر رقم محلي معقول — الهدف منع الإرسال الفاضي أو الناقص بوضوح،
  /// مش فرض صيغة دولية صارمة على أرقام محلية.
  static const int _minDigits = 7;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length < _minDigits) {
      setState(() => _errorMessage = 'volunteer_phone_invalid'.tr());
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final result = await sl<VolunteerForProjectUseCase>()(
      VolunteerForProjectParams(
        projectId: widget.project.id,
        phoneNumber: _phoneController.text.trim(),
      ),
    );

    if (!mounted) return;

    setState(() {
      _submitting = false;
      _submitted = result.isOk;
      // سبب الرفض بيوصل كرسالة إنجليزية من الباك اند (سبع حالات منطق
      // أعمال مختلفة) — بتتحوّل لعربي هون. راجع `VolunteerRejectionMessage`.
      _errorMessage = result.isOk
          ? null
          : VolunteerRejectionMessage.resolve(result.failureOrNull!.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      contentPadding: EdgeInsets.all(20.w),
      content: _submitted ? _buildSuccess(context) : _buildForm(context),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, size: 44.sp, color: colors.success),
        SizedBox(height: 8.h),
        Text(
          'volunteer_success_title'.tr(),
          textAlign: TextAlign.center,
          style: context.texts.f16W500Black.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'volunteer_success_sub'.tr(),
          textAlign: TextAlign.center,
          style: context.texts.f12W400SecColor.copyWith(height: 1.4),
        ),
        SizedBox(height: 18.h),
        SizedBox(
          width: double.infinity,
          height: 46.h,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md.r),
              ),
            ),
            child: Text('close'.tr()),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    final scheme = context.scheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'volunteer_dialog_title'.tr(
            namedArgs: {'project': widget.project.title},
          ),
          style: context.texts.f16W500Black.copyWith(
            fontSize: 15.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'volunteer_dialog_sub'.tr(),
          style: context.texts.f12W400SecColor.copyWith(height: 1.45),
        ),
        SizedBox(height: AppSpacing.md.h),
        Text(
          'volunteer_phone_label'.tr(),
          style: context.texts.f14W600Black.copyWith(fontSize: 12.sp),
        ),
        SizedBox(height: 6.h),
        CustomTextFormField(
          controller: _phoneController,
          validationMessage: (_) => null,
          keyBoardType: TextInputType.phone,
          hintText: 'volunteer_phone_hint'.tr(),
          maxLength: 20,
          digitsOnly: true,
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
        ),
        if (_errorMessage != null) ...[
          SizedBox(height: 6.h),
          Text(
            _errorMessage!,
            style: TextStyle(fontSize: 11.5.sp, color: scheme.error),
          ),
        ],
        SizedBox(height: AppSpacing.md.h),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46.h,
                child: OutlinedButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.textPrimary,
                    side: BorderSide(color: context.colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md.r),
                    ),
                  ),
                  child: Text('cancel'.tr()),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: SizedBox(
                height: 46.h,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
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
                            color: scheme.onPrimary,
                          ),
                        )
                      : Text('volunteer_confirm'.tr()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
