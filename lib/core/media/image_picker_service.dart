// -------------------------
// Image Picker Service
// -------------------------

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'picked_image.dart';

/// ألوان شاشة القص. بتنبنى من الثيم بطبقة الواجهة وبتنمرّر لهون، فالخدمة
/// بتضل بلا `BuildContext` وبتنختبر بلا شجرة widgets.
final class CropperAppearance {
  final String toolbarTitle;
  final Color toolbarColor;
  final Color toolbarWidgetColor;
  final Color backgroundColor;
  final Color activeControlsWidgetColor;
  final bool isDark;

  const CropperAppearance({
    required this.toolbarTitle,
    required this.toolbarColor,
    required this.toolbarWidgetColor,
    required this.backgroundColor,
    required this.activeControlsWidgetColor,
    required this.isDark,
  });
}

/// خط أنابيب صورة الملف الشخصي: **اختيار ← قص ← ضغط**.
///
/// الرفع مش من مسؤوليتها — بترجّع [PickedImage] وطبقة الـ data بترفع.
/// هيك بتضل الخدمة عن المنصّة بحتة وبلا أي معرفة بالـ endpoints.
///
/// ليش الخطوات الثلاث مع بعض؟ لأن كل وحدة بتقلّل حجم اللي بعدها:
/// `pickImage` بتحدّ الأبعاد، القص بيرمي كل شي برّا المربّع، والضغط
/// بيوصل الناتج لعشرات الكيلوبايت. صورة كاميرا خام (~5MB) على شبكة
/// موبايل ضعيفة بتفشل أو بتاخد دقيقة.
class ImagePickerService {
  final ImagePicker _picker;
  final ImageCropper _cropper;

  ImagePickerService({ImagePicker? picker, ImageCropper? cropper})
    : _picker = picker ?? ImagePicker(),
      _cropper = cropper ?? ImageCropper();

  /// ضلع الصورة النهائية. 512 كافية لدائرة 112 حتى على شاشة 3x.
  static const int _targetSize = 512;

  /// 85 نقطة التوازن المعتادة: فوقها الحجم بيقفز بلا فرق يشوفه العين.
  static const int _quality = 85;

  /// بترجّع `null` لو المستخدم لغى بأي خطوة — الإلغاء مش خطأ.
  Future<PickedImage?> pickAvatar({
    required ImageSource source,
    required CropperAppearance appearance,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      // حدّ أولي قبل ما تدخل الصورة الذاكرة — صور الكاميرا الحديثة
      // بتوصل 12MP وفتحها بحجمها الكامل بيخنق الأجهزة الضعيفة.
      maxWidth: 1440,
      maxHeight: 1440,
      imageQuality: 90,
    );

    if (picked == null) return null;

    final cropped = await _cropAvatar(picked.path, appearance);

    if (cropped == null) return null;

    final bytes = await FlutterImageCompress.compressWithFile(
      cropped.path,
      minWidth: _targetSize,
      minHeight: _targetSize,
      quality: _quality,
      format: CompressFormat.jpeg,
      // بيانات EXIF فيها موقع التصوير أحياناً — ما بنرفعها مع صورة
      // بروفايل عامة.
      keepExif: false,
    );

    if (bytes == null) return null;

    final file = await _writeTempJpeg(bytes);

    return PickedImage(
      path: file.path,
      bytes: bytes,
      fileName: _fileNameOf(file.path),
    );
  }

  Future<CroppedFile?> _cropAvatar(
    String sourcePath,
    CropperAppearance appearance,
  ) {
    return _cropper.cropImage(
      sourcePath: sourcePath,
      // مربّع مقفول: الأفاتار دائرة، وأي نسبة ثانية بتنقص منها.
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: _targetSize,
      maxHeight: _targetSize,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: appearance.toolbarTitle,
          toolbarColor: appearance.toolbarColor,
          toolbarWidgetColor: appearance.toolbarWidgetColor,
          backgroundColor: appearance.backgroundColor,
          activeControlsWidgetColor: appearance.activeControlsWidgetColor,
          statusBarLight: !appearance.isDark,
          // إطار القص دائرة، فاللي بيشوفه المستخدم وقت القص هو نفسه
          // اللي رح يطلع بالشاشة.
          cropStyle: CropStyle.circle,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: appearance.toolbarTitle,
          cropStyle: CropStyle.circle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );
  }

  /// ملف مؤقّت للعرض الفوري. مؤقّت عن قصد: النسخة الدائمة عند السيرفر،
  /// والنظام بينضّف مجلده لحاله.
  static Future<File> _writeTempJpeg(List<int> bytes) async {
    final name = 'maan_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File('${Directory.systemTemp.path}${Platform.pathSeparator}$name');

    return file.writeAsBytes(bytes, flush: true);
  }

  static String _fileNameOf(String path) {
    final separator = path.lastIndexOf(RegExp(r'[/\\]'));

    return separator == -1 ? path : path.substring(separator + 1);
  }
}
