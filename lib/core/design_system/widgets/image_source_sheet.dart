// -------------------------
// Image Source Sheet
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_spacing.dart';
import '../app_theme_context.dart';

/// خيار المستخدم بورقة اختيار الصورة.
enum ImageSourceAction {
  camera,
  gallery,

  /// إزالة صورة موجودة — بتظهر بس لما [showImageSourceSheet] تتنادى مع
  /// `showRemoveOption: true`. صور التوثيق ما بتستخدمها: بعد الإرسال
  /// الصور ما بتتغيّر (راجع `VerificationRepository.update`).
  remove,
}

/// «من وين بدك الصورة؟» — كاميرا أو معرض، وإزالة اختيارية.
///
/// كانت `AvatarSourceSheet` بميزة profile — انتقلت لـ`core` لما احتاجتها
/// شاشة التوثيق كمان بنفس البنية حرفياً (نفس سبب انتقال `AppCard`
/// و`BirthDate`). الفرق الوحيد بين الاستخدامين نص العنوان، فصار وسيطاً
/// بدل ما ينتسخ الودجت.
///
/// كل النصوص بتوصل **مترجَمة** من مكان الاستدعاء لا كمفاتيح: الودجت
/// بـ`core` ما بيعرف مفاتيح ميزة، وماسح الترجمة بـ
/// `test/localization/localization_test.dart` بيتطلّب المفتاح يكون نصاً
/// حرفياً قبل `.tr()` مباشرة.
///
/// بترجّع `null` لو سكّرها المستخدم بلا اختيار.
Future<ImageSourceAction?> showImageSourceSheet(
  BuildContext context, {
  required String title,
  required String cameraLabel,
  required String galleryLabel,
  bool showRemoveOption = false,
  String? removeLabel,
}) {
  return showModalBottomSheet<ImageSourceAction>(
    context: context,
    backgroundColor: context.scheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg.r)),
    ),
    builder: (sheetContext) => _ImageSourceSheet(
      title: title,
      showRemoveOption: showRemoveOption,
      cameraLabel: cameraLabel,
      galleryLabel: galleryLabel,
      removeLabel: removeLabel,
    ),
  );
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet({
    required this.title,
    required this.showRemoveOption,
    required this.cameraLabel,
    required this.galleryLabel,
    required this.removeLabel,
  });

  final String title;
  final bool showRemoveOption;
  final String cameraLabel;
  final String galleryLabel;
  final String? removeLabel;

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
                  title,
                  style: context.texts.f16W500Black.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            _SourceTile(
              icon: Icons.photo_camera_rounded,
              label: cameraLabel,
              action: ImageSourceAction.camera,
            ),
            _SourceTile(
              icon: Icons.photo_library_rounded,
              label: galleryLabel,
              action: ImageSourceAction.gallery,
            ),

            if (showRemoveOption && removeLabel != null)
              _SourceTile(
                icon: Icons.delete_outline_rounded,
                label: removeLabel!,
                action: ImageSourceAction.remove,
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
  final ImageSourceAction action;
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
