// -------------------------
// Complaint Media Source Sheet
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';

/// ثلاث خيارات لا اثنين متل [showImageSourceSheet] — دليل الشكوى بيقبل
/// فيديو كمان، وهاد ما بينطبق على مسار صورة البروفايل/الوثيقة. ملف
/// مستقل بدل تعديل الودجت العامة بحالة خاصة بميزة وحدة.
enum ComplaintMediaSource { camera, gallery, video }

Future<ComplaintMediaSource?> showComplaintMediaSourceSheet(
  BuildContext context,
) {
  return showModalBottomSheet<ComplaintMediaSource>(
    context: context,
    backgroundColor: context.scheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg.r)),
    ),
    builder: (context) => const _MediaSourceSheet(),
  );
}

class _MediaSourceSheet extends StatelessWidget {
  const _MediaSourceSheet();

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
                  'media_sheet_title'.tr(),
                  style: context.texts.f16W500Black.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _Tile(
              icon: Icons.photo_camera_rounded,
              label: 'media_camera'.tr(),
              source: ComplaintMediaSource.camera,
            ),
            _Tile(
              icon: Icons.photo_library_rounded,
              label: 'media_gallery'.tr(),
              source: ComplaintMediaSource.gallery,
            ),
            _Tile(
              icon: Icons.videocam_rounded,
              label: 'media_video'.tr(),
              source: ComplaintMediaSource.video,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.source});

  final IconData icon;
  final String label;
  final ComplaintMediaSource source;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.scheme.primary),
      title: Text(label, style: context.texts.f16W400Black),
      onTap: () => Navigator.of(context).pop(source),
    );
  }
}
