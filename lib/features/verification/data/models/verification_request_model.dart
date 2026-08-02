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

  const VerificationRequestModel({
    required this.id,
    required this.userId,
    required this.nationalId,
    required this.status,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
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
    );
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
