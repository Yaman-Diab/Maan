// -------------------------
// Skill Delete Sheet
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/confirm_sheet.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../domain/usecases/delete_skill_usecase.dart';

/// بترجّع `true` لو انحذفت المهارة فعلياً — الشاشة المستدعية بتتصرّف
/// حسب القيمة (رجوع من التفاصيل، أو إعادة تحميل القائمة).
Future<bool> confirmAndDeleteSkill(
  BuildContext context, {
  required int skillId,
}) async {
  final confirmed = await showConfirmSheet(
    context: context,
    title: 'skills_delete_confirm_title'.tr(),
    body: 'skills_delete_confirm_body'.tr(),
    confirmLabel: 'delete'.tr(),
    confirmColor: context.scheme.error,
  );

  if (!confirmed || !context.mounted) return false;

  final result = await sl<DeleteSkillUseCase>()(skillId);

  if (!context.mounted) return false;

  if (result.isOk) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('skills_toast_deleted'.tr())));
    return true;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(result.failureOrNull!.message)));
  return false;
}
