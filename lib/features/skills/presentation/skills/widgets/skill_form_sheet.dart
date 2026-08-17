// -------------------------
// Skill Form Sheet
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/custom_text_form_field.dart';
import '../../../../../core/design_system/widgets/labeled_field.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/skill_type.dart';
import '../../../domain/usecases/add_skill_usecase.dart';
import '../../../domain/usecases/update_skill_usecase.dart';
import '../../shared/skill_style.dart';

/// إضافة مهارة (`skill == null`) أو تعديلها — بترجّع `true` بعد نجاح
/// الحفظ حتى الشاشة المستدعية تعيد التحميل، نفس نمط `ComplaintReportSheet`.
Future<bool> showSkillFormSheet(BuildContext context, {Skill? skill}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SkillFormSheet(skill: skill),
  );

  return result ?? false;
}

class _SkillFormSheet extends StatefulWidget {
  const _SkillFormSheet({this.skill});

  final Skill? skill;

  @override
  State<_SkillFormSheet> createState() => _SkillFormSheetState();
}

class _SkillFormSheetState extends State<_SkillFormSheet> {
  late final _nameController = TextEditingController(
    text: widget.skill?.name ?? '',
  );
  late SkillType _type = widget.skill?.type ?? SkillType.technical;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty && !_saving;

  Future<void> _save() async {
    if (!_canSave) return;

    setState(() => _saving = true);

    final name = _nameController.text.trim();
    final skill = widget.skill;

    final result = skill == null
        ? await sl<AddSkillUseCase>()(AddSkillParams(name: name, type: _type))
        : await sl<UpdateSkillUseCase>()(
            UpdateSkillParams(skillId: skill.id, name: name, type: _type),
          );

    if (!mounted) return;

    setState(() => _saving = false);

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
    final isEdit = widget.skill != null;

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
                        isEdit
                            ? 'skills_edit_sheet_title'.tr()
                            : 'skills_add_sheet_title'.tr(),
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
                Text(
                  'skills_form_helper'.tr(),
                  style: context.texts.f12W400SecColor,
                ),
                SizedBox(height: AppSpacing.md.h),
                LabeledField(
                  label: 'skills_name_label'.tr(),
                  child: CustomTextFormField(
                    controller: _nameController,
                    validationMessage: (_) => null,
                    keyBoardType: TextInputType.text,
                    hintText: 'skills_name_hint'.tr(),
                    maxLength: 200,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        'skills_type_section_label'.tr(),
                        style: context.texts.f14W600Black,
                      ),
                    ),
                    Text(
                      'skills_type_section_hint'.tr(),
                      style: TextStyle(fontSize: 11.sp, color: colors.textHint),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 1.05,
                  children: [
                    for (final type in SkillType.values)
                      Builder(
                        builder: (context) {
                          final style = SkillStyle.type(context, type);
                          final selected = type == _type;

                          return InkWell(
                            onTap: () => setState(() => _type = type),
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected
                                    ? style.background
                                    : Colors.transparent,
                                border: Border.all(
                                  color: selected
                                      ? style.foreground
                                      : colors.border,
                                  width: selected ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    style.icon,
                                    size: 21.sp,
                                    color: selected
                                        ? style.foreground
                                        : colors.textSecondary,
                                  ),
                                  SizedBox(height: 6.h),
                                  // `FittedBox` بدل `Text` مباشرة — تسمية
                                  // طويلة أو مقياس خط نظام أكبر بيصغّر
                                  // بدل ما يكسر ارتفاع الخلية الثابت
                                  // (`childAspectRatio`) — نفس إصلاح
                                  // `_CategoryTile` بميزة الشكاوى.
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          style.label,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: selected
                                                ? style.foreground
                                                : colors.textSecondary,
                                            height: 1.25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: FilledButton.icon(
                    onPressed: _canSave ? _save : null,
                    icon: _saving
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text('skills_save_cta'.tr()),
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
}
