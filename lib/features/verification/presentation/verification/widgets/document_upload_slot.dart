// -------------------------
// Document Upload Slot
// -------------------------

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/media/picked_image.dart';

/// خانة صورة وحدة بنموذج التوثيق — فاضية (منطقة رفع منقّطة) أو معبّاية
/// (معاينة + اسم + حجم + زر حذف).
///
/// الحالتان بودجت واحد لأن التصميم بيبدّل بينهما بنفس المكان، ومفيش حالة
/// تالتة: الرفع نفسه بيصير مرّة وحدة عند الإرسال لا لكل صورة على حدة.
class DocumentUploadSlot extends StatelessWidget {
  const DocumentUploadSlot({
    super.key,
    required this.label,
    required this.image,
    required this.onPick,
    required this.onRemove,
    required this.isEnabled,
  });

  final String label;
  final PickedImage? image;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  /// بوضع «تصحيح رقم وطني» الصور مقفولة — العقد المؤكّد لـ
  /// `POST /api/verification/update` ما بيشمل الصور (راجع
  /// `VerificationRepository.update`).
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final picked = image;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: context.texts.f14W600Black,
        ),
        SizedBox(height: AppSpacing.xs.h),
        if (picked == null)
          _EmptySlot(onPick: onPick, isEnabled: isEnabled)
        else
          _FilledSlot(
            image: picked,
            onRemove: onRemove,
            isEnabled: isEnabled,
          ),
      ],
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.onPick, required this.isEnabled});

  final VoidCallback onPick;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: isEnabled ? onPick : null,
      borderRadius: BorderRadius.circular(AppRadius.md.r),
      child: DottedBorderBox(
        color: colors.border,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.lg.h,
            horizontal: AppSpacing.sm.w,
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 28.sp,
                color: isEnabled ? context.scheme.primary : colors.textHint,
              ),
              SizedBox(height: AppSpacing.xxs.h),
              Text(
                'verification_upload_cta'.tr(),
                textAlign: TextAlign.center,
                style: context.texts.f12W400SecColor,
              ),
              SizedBox(height: 2.h),
              Text(
                'verification_upload_hint'.tr(),
                textAlign: TextAlign.center,
                style: context.texts.f12W400SecColor.copyWith(
                  color: colors.textHint,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilledSlot extends StatelessWidget {
  const _FilledSlot({
    required this.image,
    required this.onRemove,
    required this.isEnabled,
  });

  final PickedImage image;
  final VoidCallback onRemove;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;

    return Container(
      padding: EdgeInsets.all(AppSpacing.xs.w),
      decoration: BoxDecoration(
        color: colors.brandSurface,
        border: Border.all(color: scheme.primary),
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm.r),
            child: Image.file(
              File(image.path),
              width: 52.w,
              height: 40.h,
              fit: BoxFit.cover,
              // الملف مؤقّت وممكن ينمسح من النظام — بلا هالحارس الشاشة
              // بتنهار بدل ما تعرض بديل.
              errorBuilder: (context, error, stackTrace) => Container(
                width: 52.w,
                height: 40.h,
                color: colors.fieldBackground,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 18.sp,
                  color: colors.textHint,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  image.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.f14W600Black,
                ),
                Text(
                  _formatSize(image.sizeInBytes),
                  style: context.texts.f12W400SecColor,
                ),
              ],
            ),
          ),
          if (isEnabled)
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20.sp,
                color: scheme.error,
              ),
              tooltip: 'verification_remove_photo'.tr(),
            ),
        ],
      ),
    );
  }

  /// عرض بالميغابايت زي التصميم. مش `intl` لأن الرقم تقني بحت (حجم ملف)
  /// وما بيتبع تنسيق الأرقام حسب اللغة بأي تطبيق.
  static String _formatSize(int bytes) {
    final mb = bytes / (1024 * 1024);

    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';

    final kb = bytes / 1024;

    return '${kb.toStringAsFixed(0)} KB';
  }
}

/// إطار منقّط. Flutter ما بيدعم `border-style: dashed` أصلاً، فالرسم
/// بـ`CustomPaint` بدل ما ننزّل حزمة كاملة لخط منقّط واحد.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: AppRadius.md.r,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);

    const dash = 5.0;
    const gap = 4.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;

      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
