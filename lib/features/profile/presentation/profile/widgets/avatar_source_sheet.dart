// -------------------------
// Avatar Source Sheet
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';

/// «من وين بدك الصورة؟» — كاميرا أو معرض.
///
/// بترجّع `null` لو سكّرها المستخدم بلا اختيار.
Future<ImageSource?> showAvatarSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: context.scheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg.r)),
    ),
    builder: (sheetContext) => const _AvatarSourceSheet(),
  );
}

class _AvatarSourceSheet extends StatelessWidget {
  const _AvatarSourceSheet();

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
              source: ImageSource.camera,
            ),
            _SourceTile(
              icon: Icons.photo_library_rounded,
              label: 'avatar_source_gallery'.tr(),
              source: ImageSource.gallery,
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
    required this.source,
  });

  final IconData icon;
  final String label;
  final ImageSource source;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.scheme.primary),
      title: Text(label, style: context.texts.f16W400Black),
      onTap: () => Navigator.of(context).pop(source),
    );
  }
}
