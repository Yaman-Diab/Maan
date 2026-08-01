// -------------------------
// Profile Remote Data Source
// -------------------------

import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_keys.dart';
import '../models/citizen_profile_model.dart';

/// المكان الوحيد اللي بيعرف الـ endpoint داخل ميزة profile.
///
/// بيرمي `ApiException` كما هي — تحويلها لـ`Failure` مسؤولية
/// `ProfileRepositoryImpl`.
abstract class ProfileRemoteDataSource {
  Future<CitizenProfileModel> getProfile();

  /// بترجّع رابط الصورة الجديد لو رجّعه السيرفر.
  Future<String?> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  const ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<CitizenProfileModel> getProfile() async {
    // بلا `skipAuthHeader`: هذا مسار محمي، فالـ interceptor بيضيف
    // الـ Bearer token.
    final response = await _apiClient.request(
      endpoint: ApiEndpoints.profile,
      method: ApiMethod.get,
    );

    return CitizenProfileModel.fromMap(_asJsonMap(response));
  }

  /// الصورة بتنرفع عبر `POST /api/profile/update` — مسار تحديث الملف
  /// الشخصي العام، لا endpoint مخصّص للصورة.
  ///
  /// منبعت **حقل الصورة لحاله**: الباك اند بيحدّث اللي وصله فقط، فإرسال
  /// باقي الحقول معه بيخاطر بالكتابة فوق قيم ما قصد المستخدم يغيّرها.
  ///
  /// ⚠️ **اسم الحقل غير مؤكّد** — `avatar` تخمين باصطلاح Laravel. أي
  /// تصحيح بينطبق على [_avatarField] وبس.
  @override
  Future<String?> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      _avatarField: MultipartFile.fromBytes(bytes, filename: fileName),
    });

    final response = await _apiClient.request(
      endpoint: ApiEndpoints.profileUpdate,
      method: ApiMethod.post,
      data: formData,
    );

    return _readAvatarUrl(response);
  }

  static const String _avatarField = 'avatar';

  /// الرابط ممكن يرجع بالجذر أو تحت `data` أو ما يرجع أبداً. `null`
  /// نتيجة صحيحة: الواجهة أصلاً بتعرض الملف المحلي بعد الرفع.
  static String? _readAvatarUrl(dynamic response) {
    final json = response is Map ? Map<String, dynamic>.from(response) : null;

    if (json == null) return null;

    final data = json[ApiResponseKeys.data];
    final container = data is Map ? Map<String, dynamic>.from(data) : json;

    for (final key in ['avatar_url', 'avatar', 'image_url', 'image', 'url']) {
      final value = container[key];

      if (value is String && value.trim().isNotEmpty) return value;
    }

    return null;
  }

  static Map<String, dynamic> _asJsonMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);

    throw const FormatException('Unexpected response format');
  }
}
