// -------------------------
// Certificate Model
// -------------------------

import '../../../../core/network/api_response_keys.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/entities/certificate_rejection_reason.dart';
import '../../domain/entities/certificate_status.dart';

/// قراءة عنصر شهادة من `GET /api/certificate`.
///
/// ⚠️ **الشكل غير مؤكّد بمثال استجابة حقيقي** — الـcollection عندها
/// مثال الإرسال (`user_skill_id`+`file_path`) بس. `id`/`user_skill_id`
/// مفروضين يتطابقوا لأنهم نفس أسماء الإرسال؛ اسم الملف بالقراءة مخمَّن
/// (أكتر من اسم محتمل مجرَّب بالترتيب)، و`rejection_reason` بيرجع
/// `null` بدل ما يفشّل العنصر لو الحالة مش `rejected`.
class CertificateModel {
  final Certificate entity;

  const CertificateModel(this.entity);

  factory CertificateModel.fromMap(Map<String, dynamic> json) {
    final id = json['id'];
    final skillId = json['user_skill_id'];

    if (id is! int || skillId is! int) {
      throw const FormatException(
        'Certificate data is missing required fields.',
      );
    }

    final status = CertificateStatus.fromApi(json['status'] as String?);

    return CertificateModel(
      Certificate(
        id: id,
        skillId: skillId,
        status: status,
        fileName: _firstString(json, [
          'file_name',
          'file_path',
          'file',
          'file_url',
        ]),
        rejectionReason: status == CertificateStatus.rejected
            ? CertificateRejectionReason.fromApi(
                json['rejection_reason'] as String?,
              )
            : null,
      ),
    );
  }

  static List<Certificate> listFromResponse(dynamic response) {
    final result = <Certificate>[];

    for (final item in _extractList(response)) {
      if (item is! Map) continue;

      try {
        result.add(
          CertificateModel.fromMap(Map<String, dynamic>.from(item)).entity,
        );
      } on FormatException {
        continue;
      }
    }

    return result;
  }

  static List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;

    if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      final data = map[ApiResponseKeys.data];

      if (data != null) return _extractList(data);
    }

    return const [];
  }

  static String? _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value is String && value.isNotEmpty) {
        // بعض الأسماء المحتملة روابط/مسارات كاملة — نعرض اسم الملف
        // الأخير بس، نفس منطق ImagePickerService._fileNameOf.
        final separator = value.lastIndexOf(RegExp(r'[/\\]'));

        return separator == -1 ? value : value.substring(separator + 1);
      }
    }

    return null;
  }
}
