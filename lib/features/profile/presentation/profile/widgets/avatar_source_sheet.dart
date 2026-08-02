// -------------------------
// Avatar Source Sheet
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';

/// خيار المستخدم بورقة اختيار الصورة.
enum AvatarSourceAction {
  camera,
  gallery,

  /// راجع تحذير العقد بـ`ProfileRepository.removeAvatar` — الإزالة نفسها
  /// عبر نفس مسار الرفع بحقل فاضي، مش endpoint مخصّص.
  remove,
}

/// «من وين بدك الصورة؟» — كاميرا أو معرض، وإزالة لو في صورة أصلاً.
///
/// [showRemoveOption] بيتحكّم بظهور «إزالة الصورة» — ما إلها معنى لو ما
/// في صورة حالياً (محلية ولا من السيرفر).
///
/// بترجّع `null` لو سكّرها المستخدم بلا اختيار.
Future<AvatarSourceAction?> showAvatarSourceSheet(
  BuildContext context, {
  bool showRemoveOption = false,
}) {
  return showModalBottomSheet<AvatarSourceAction>(
    context: context,
    backgroundColor: context.scheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg.r)),
    ),
    builder: (sheetContext) =>
        _AvatarSourceSheet(showRemoveOption: showRemoveOption),
  );
}

class _AvatarSourceSheet extends StatelessWidget {
  const _AvatarSourceSheet({required this.showRemoveOption});

  final bool showRemoveOption;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'avatar_sheet_title'.tr(),
                  style: context.texts.f16W500Black.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            _SourceTile(
              icon: Icons.photo_camera_rounded,
              label: 'avatar_source_camera'.tr(),
              action: AvatarSourceAction.camera,
            ),
            _SourceTile(
              icon: Icons.photo_library_rounded,
              label: 'avatar_source_gallery'.tr(),
              action: AvatarSourceAction.gallery,
            ),

            if (showRemoveOption)
              _SourceTile(
                icon: Icons.delete_outline_rounded,
                label: 'avatar_source_remove'.tr(),
                action: AvatarSourceAction.remove,
                // الإزالة إجراء هدّام (بيمسح صورة موجودة)، فبتاخد لون
                // التحذير متل زر تسجيل الخروج — نفس الاصطلاح بكل مكان
                // بالتطبيق.
                isDestructive: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.action,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final AvatarSourceAction action;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? context.scheme.error : context.scheme.primary;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: context.texts.f16W400Black.copyWith(
          color: isDestructive ? color : null,
        ),
      ),
      onTap: () => Navigator.of(context).pop(action),
    );
  }
}
