// -------------------------
// Certificate File Picker Service
// -------------------------

import 'package:file_picker/file_picker.dart';

/// ملف شهادة إثبات مختار — PDF أو صورة، بلا معالجة (الشهادة بتترفع
/// كما هي، نفس منطق `PickedComplaintMedia`).
final class PickedCertificateFile {
  final String path;
  final String fileName;
  final int sizeInBytes;

  const PickedCertificateFile({
    required this.path,
    required this.fileName,
    required this.sizeInBytes,
  });
}

/// اختيار ملف شهادة (PDF/JPG/PNG) — عام بـ`core/` نفس سبب
/// `ImagePickerService`: أول مستهلك بس، وأي ميزة ثانية تحتاج رفع ملف
/// عام (لا صورة بروفايل مقصوصة) بتلاقي مكانها هون.
class CertificateFilePickerService {
  const CertificateFilePickerService();

  /// 5 ميغابايت — نفس الحد المعروض بواجهة الرفع.
  static const int maxSizeInBytes = 5 * 1024 * 1024;

  /// بترجّع `null` لو المستخدم لغى الاختيار **أو** تجاوز الملف الحجم
  /// المسموح — الفرق بينهما مسؤولية الواجهة المستدعية (`wasOversized`).
  Future<PickedCertificateFile?> pickFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (file == null || file.path == null) return null;

    return PickedCertificateFile(
      path: file.path!,
      fileName: file.name,
      sizeInBytes: await file.length(),
    );
  }
}
