// -------------------------
// Verification Remote Data Source
// -------------------------

import 'package:dio/dio.dart';

import '../../../../core/media/picked_image.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/verification_request_model.dart';

/// المكان الوحيد اللي بيعرف Dio والـ endpoint داخل ميزة verification.
abstract class VerificationRemoteDataSource {
  Future<VerificationRequestModel> submit({
    required String nationalId,
    required List<PickedImage> images,
  });

  Future<VerificationRequestModel> update({
    required int requestId,
    required String nationalId,
  });
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final ApiClient _apiClient;

  const VerificationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<VerificationRequestModel> submit({
    required String nationalId,
    required List<PickedImage> images,
  }) async {
    final formData = FormData.fromMap({_nationalIdField: nationalId});

    // ما بنستخدم `FormData.fromMap({'images': [...]})`: بوضع Dio
    // الافتراضي (`ListFormat.multi`) بيكرّر اسم الحقل **بلا** `[]`
    // (`images`, `images`, ...)، وPHP/Laravel ما بيجمعهم بمصفوفة إلا لو
    // الاسم نفسه منتهي بـ`[]` على مستوى السلك. فبنضيف الملفات يدوياً
    // بمفتاح `images[]` صريح.
    for (final image in images) {
      formData.files.add(
        MapEntry(
          _imagesField,
          MultipartFile.fromBytes(image.bytes, filename: image.fileName),
        ),
      );
    }

    final response = await _apiClient.request(
      endpoint: ApiEndpoints.verificationStore,
      method: ApiMethod.post,
      data: formData,
    );

    return VerificationRequestModel.fromMap(_asJsonMap(response));
  }

  /// ⚠️ الصور مش جزء من هالطلب — العقد المؤكّد بس `id` + `national_id`.
  /// راجع تحذير `VerificationRepository.update`.
  @override
  Future<VerificationRequestModel> update({
    required int requestId,
    required String nationalId,
  }) async {
    final formData = FormData.fromMap({
      _requestIdField: requestId,
      _nationalIdField: nationalId,
    });

    final response = await _apiClient.request(
      endpoint: ApiEndpoints.verificationUpdate,
      method: ApiMethod.post,
      data: formData,
    );

    return VerificationRequestModel.fromMap(_asJsonMap(response));
  }

  static const String _requestIdField = 'id';
  static const String _nationalIdField = 'national_id';
  static const String _imagesField = 'images[]';

  static Map<String, dynamic> _asJsonMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);

    throw const FormatException('Unexpected response format');
  }
}
