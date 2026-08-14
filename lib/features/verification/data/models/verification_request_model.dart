// -------------------------
// Verification Request Model
// -------------------------

import '../../../../core/network/api_response_keys.dart';
import '../../domain/entities/verification_request.dart';
import '../../domain/entities/verification_request_status.dart';

class VerificationImageModel {
  final int id;
  final String imageUrl;

  const VerificationImageModel({required this.id, required this.imageUrl});

  factory VerificationImageModel.fromMap(Map<String, dynamic> json) {
    final id = json['id'];
    final imageUrl = json['image_url'] as String?;

    if (id is! int || imageUrl == null) {
      throw const FormatException(
        'Verification image data is missing required fields.',
      );
    }

    return VerificationImageModel(id: id, imageUrl: imageUrl);
  }

  VerificationImage toEntity() {
    return VerificationImage(id: id, imageUrl: imageUrl);
  }
}

/// قراءة استجابة `POST /api/verification/store` كما وصلت فعلياً —
/// راجع مثال حقيقي بـ`CLAUDE.md` › قسم التوثيق.
class VerificationRequestModel {
  final int id;
  final int userId;
  final String nationalId;
  final VerificationRequestStatus status;
  final List<VerificationImageModel> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? rejectionReason;
  final String? rejectionDescription;

  const VerificationRequestModel({
    required this.id,
    required this.userId,
    required this.nationalId,
    required this.status,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    this.rejectionReason,
    this.rejectionDescription,
  });

  factory VerificationRequestModel.fromMap(Map<String, dynamic> json) {
    final data = _normalizeResponseData(json);

    final id = data['id'];
    final userId = data['user_id'];
    final nationalId = data['national_id'] as String?;
    final createdAt = _tryParseDate(data['created_at']);
    final updatedAt = _tryParseDate(data['updated_at']);

    if (id is! int ||
        userId is! int ||
        nationalId == null ||
        createdAt == null ||
        updatedAt == null) {
      throw const FormatException(
        'Verification request data is missing required fields.',
      );
    }

    final imagesJson = data['images'];
    final images = imagesJson is List
        ? imagesJson
              .whereType<Map>()
              .map(
                (image) => VerificationImageModel.fromMap(
                  Map<String, dynamic>.from(image),
                ),
              )
              .toList()
        : const <VerificationImageModel>[];

    return VerificationRequestModel(
      id: id,
      userId: userId,
      nationalId: nationalId,
      status: VerificationRequestStatus.fromApi(data['status'] as String?),
      images: images,
      createdAt: createdAt,
      updatedAt: updatedAt,
      rejectionReason: _asNonEmptyString(data['reason']),
      rejectionDescription: _asNonEmptyString(data['description']),
    );
  }

  VerificationRequest toEntity() {
    return VerificationRequest(
      id: id,
      userId: userId,
      nationalId: nationalId,
      status: status,
      images: images.map((image) => image.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      rejectionReason: rejectionReason,
      rejectionDescription: rejectionDescription,
    );
  }

  /// قراءة استجابة `GET /api/verification` بلا رهان على شكل واحد.
  ///
  /// ✅ **الشكل الأساسي مؤكّد من رد حقيقي**: `{"data":[{...}]}` — قائمة
  /// كائنات كاملة تحت `data` (كل كائن فيه أيضاً `user` مضمّن كامل و
  /// `rejections` مصفوفة، غير مقروءين هون حالياً — راجع الملاحظات تحت).
  /// بنضل نقبل الأشكال التانية الممكنة دفاعياً (قائمة مباشرة، كائن
  /// مفرد، `data.data` تبع ترقيم Laravel) لأنه ما إلها كلفة إضافية.
  /// العنصر اللي ما بينقرأ بينترمى بصمت بدل ما يوقّع الاستجابة كلها:
  /// طلب قديم بشكل مختلف ما لازم يمنع عرض الطلب الحالي.
  ///
  /// ⚠️ **`user` المضمّن مش مقروء عمداً** — `VerificationCubit` بيجيب
  /// بيانات المستخدم من `GET /api/profile` بالتوازي (مصدر أحدث/أشمل)،
  /// فمافي داعي لتكرار التحليل هون. لو صار `VerificationRequest` محتاج
  /// حقل مستخدم يوماً، هاد أقرب مصدر جاهز.
  static List<VerificationRequestModel> listFromResponse(dynamic response) {
    final items = _extractList(response);

    final models = <VerificationRequestModel>[];
    for (final item in items) {
      if (item is! Map) continue;

      try {
        models.add(
          VerificationRequestModel.fromMap(Map<String, dynamic>.from(item)),
        );
      } on FormatException {
        continue;
      }
    }

    return models;
  }

  static List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;

    if (response is Map) {
      final map = Map<String, dynamic>.from(response);

      // كائن مفرد وصل مباشرة بلا تغليف.
      if (map.containsKey('national_id')) return [map];

      final data = map[ApiResponseKeys.data];
      if (data != null) return _extractList(data);
    }

    return const [];
  }

  static String? _asNonEmptyString(dynamic value) {
    if (value is! String) return null;

    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
  }

  /// الاستجابة الحقيقية بتغلّف البيانات تحت `data`. نفس نمط
  /// `LoginResponseModel._normalizeResponseData`.
  static Map<String, dynamic> _normalizeResponseData(
    Map<String, dynamic> json,
  ) {
    if (json.containsKey('national_id')) return json;

    final data = json[ApiResponseKeys.data];
    if (data is Map) return Map<String, dynamic>.from(data);

    return json;
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;

    return DateTime.tryParse(value);
  }
}
