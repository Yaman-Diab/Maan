// -------------------------
// Complaint Model
// -------------------------

import '../../../../core/network/api_response_keys.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/entities/complaint_category.dart';
import '../../domain/entities/complaint_status.dart';
import '../../domain/entities/complaint_type.dart';

/// قراءة عنصر شكوى من `GET /api/complains/complains` أو
/// `GET /api/complains/my-complains`.
///
/// ⚠️ **الشكل غير مؤكّد بمثال استجابة حقيقي** — Postman collection
/// عندها أمثلة الإرسال بس. الحقول الأساسية (`id`, `type`, `category_id`,
/// `title`, `status`) نفس أسماء الإرسال المؤكّدة فمتوقّع تتطابق بالقراءة
/// كمان. الحقول التانية (عدّاد الأصوات، تصويت المستخدم الحالي، وجود
/// وسائط) بأسماء مخمَّنة حسب اصطلاح Laravel الشائع — كل وحدة عندها أكتر
/// من اسم محتمل مجرَّب بالترتيب، وأي واحد ما انلقى بيرجع قيمة افتراضية
/// آمنة (`0`/`false`) بدل ما يفشل تحليل العنصر كامل. نقطة التصحيح
/// الوحيدة لما توصل استجابة حقيقية: هالملف.
class ComplaintModel {
  final Complaint entity;

  const ComplaintModel(this.entity);

  factory ComplaintModel.fromMap(Map<String, dynamic> json, {bool isMine = false}) {
    final id = json['id'];
    final type = ComplaintType.fromApi(json['type'] as String?);
    final title = json['title'] as String?;

    if (id is! int || type == null || title == null) {
      throw const FormatException('Complaint data is missing required fields.');
    }

    return ComplaintModel(
      Complaint(
        id: id,
        type: type,
        category: ComplaintCategory.fromApi(_asInt(json['category_id'])),
        status: ComplaintStatus.fromApi(json['status'] as String?),
        title: title,
        description: json['description'] as String?,
        latitude: _asDouble(json['latitude']),
        longitude: _asDouble(json['longitude']),
        votes: _firstInt(json, ['votes_count', 'votes', 'vote_count']) ?? 0,
        hasVoted: _firstBool(json, ['has_voted', 'voted', 'is_voted']) ?? false,
        hasMedia: _hasMedia(json),
        createdAt: _tryParseDate(json['created_at']),
        isMine: isMine,
      ),
    );
  }

  /// قراءة قائمة — عنصر ما بينقرأ بينترمى بصمت بدل ما يوقّع الاستجابة
  /// كلها، نفس نمط `VerificationRequestModel.listFromResponse`.
  static List<Complaint> listFromMaps(List<dynamic> items, {bool isMine = false}) {
    final result = <Complaint>[];

    for (final item in items) {
      if (item is! Map) continue;

      try {
        result.add(
          ComplaintModel.fromMap(
            Map<String, dynamic>.from(item),
            isMine: isMine,
          ).entity,
        );
      } on FormatException {
        continue;
      }
    }

    return result;
  }

  /// قراءة استجابة الـ endpoint كاملة بلا رهان على شكل تغليف واحد —
  /// نفس نمط `VerificationRequestModel.listFromResponse`: قائمة مباشرة،
  /// أو تحت `data`، أو `data.data` (ترقيم صفحات Laravel المتداخل).
  static List<Complaint> listFromResponse(dynamic response, {bool isMine = false}) {
    return listFromMaps(_extractList(response), isMine: isMine);
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

  static bool _hasMedia(Map<String, dynamic> json) {
    final media = json['media'];
    if (media is List) return media.isNotEmpty;

    final count = _firstInt(json, ['media_count']);
    if (count != null) return count > 0;

    return _firstBool(json, ['has_media']) ?? false;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);

    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);

    return null;
  }

  static int? _firstInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = _asInt(json[key]);
      if (value != null) return value;
    }

    return null;
  }

  static bool? _firstBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
    }

    return null;
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;

    return DateTime.tryParse(value);
  }
}
