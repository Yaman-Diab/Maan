// -------------------------
// Complaint Model
// -------------------------

import '../../../../core/network/api_media.dart';
import '../../../../core/network/api_response_keys.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/entities/complaint_category.dart';
import '../../domain/entities/complaint_status.dart';
import '../../domain/entities/complaint_type.dart';

/// قراءة عنصر شكوى من `GET /api/complains/complains` أو
/// `GET /api/complains/my-complains`.
///
/// ✅ **الشكل مؤكّد بأمثلة استجابة حقيقية** — `id`/`type`/`title`/
/// `status` كانت مؤكّدة أصلاً. التصنيف والموقع بيوصلوا الآن ككائنين
/// متداخلين: `category: {id,name}` (لا `category_id` مسطّح — موجود
/// بس باستجابة الإنشاء `POST /api/complains` جنب الكائن المتداخل،
/// غايب تماماً بـ`my-complains`)، والموقع تحت `location` أو `pin`
/// (اسمان مختلفان بين استجابتَي القائمة والإنشاء لنفس المفهوم!).
/// الوسائط `media: [{file_url,...}]` — روابط حقيقية أخيراً.
///
/// ⚠️ عدّاد التصويت (`votes_count`/`has_voted`...) **لسه تخمين** — كل
/// الأمثلة الحقيقية الواصلة لشكاوى المستخدم نفسه بلا أصوات، فما ثبت
/// اسم الحقل الحقيقي بعد. نقطة التصحيح الوحيدة لما يوصل مثال فيه صوت
/// فعلي: هالملف.
class ComplaintModel {
  final Complaint entity;

  const ComplaintModel(this.entity);

  factory ComplaintModel.fromMap(
    Map<String, dynamic> json, {
    bool isMine = false,
  }) {
    final id = json['id'];
    final type = ComplaintType.fromApi(json['type'] as String?);
    final title = json['title'] as String?;

    if (id is! int || type == null || title == null) {
      throw const FormatException('Complaint data is missing required fields.');
    }

    final categoryId =
        _asInt(json['category_id']) ?? _asInt(_asMap(json['category'])?['id']);
    final position = _asMap(json['location']) ?? _asMap(json['pin']);

    return ComplaintModel(
      Complaint(
        id: id,
        type: type,
        category: ComplaintCategory.fromApi(categoryId),
        status: ComplaintStatus.fromApi(json['status'] as String?),
        title: title,
        description: json['description'] as String?,
        latitude: _asDouble(position?['latitude'] ?? json['latitude']),
        longitude: _asDouble(position?['longitude'] ?? json['longitude']),
        votes: _firstInt(json, ['votes_count', 'votes', 'vote_count']) ?? 0,
        hasVoted: _firstBool(json, ['has_voted', 'voted', 'is_voted']) ?? false,
        mediaUrls: _mediaUrls(json),
        createdAt: _tryParseDate(json['created_at']),
        isMine: isMine,
      ),
    );
  }

  /// قراءة قائمة — عنصر ما بينقرأ بينترمى بصمت بدل ما يوقّع الاستجابة
  /// كلها، نفس نمط `VerificationRequestModel.listFromResponse`.
  static List<Complaint> listFromMaps(
    List<dynamic> items, {
    bool isMine = false,
  }) {
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
  static List<Complaint> listFromResponse(
    dynamic response, {
    bool isMine = false,
  }) {
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

  /// ⚠️ **الشكل بيختلف بين الإنشاء والقراءة**: `POST /api/complains`
  /// بيرجّع `file_path` بس (مسار نسبي)، بينما `my-complains` بترجّع
  /// `file_url` كامل كمان. `ApiMedia` بتتعامل مع الاثنين — راجع
  /// تعليقها للباگ الحقيقي يلي كانت الصور تختفي فيه بعد الإرسال.
  ///
  /// ⚠️ **بلا فلترة نوع هون عمداً** — بعكس الأخبار، الشكوى بتقبل فيديو
  /// كمان وبدنا نعرف إنه في وسائط أصلاً (`hasMedia`). النتيجة إن أول
  /// عنصر ممكن يكون فيديو فيفشل تحميله كصورة — فجوة موثّقة بـCLAUDE.md.
  static List<String> _mediaUrls(Map<String, dynamic> json) {
    return ApiMedia.urls(json['media']);
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);

    return null;
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
