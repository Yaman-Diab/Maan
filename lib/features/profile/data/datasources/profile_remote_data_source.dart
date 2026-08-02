// -------------------------
// Profile Remote Data Source
// -------------------------

import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_keys.dart';
import 'package:maan/core/domain/birth_date.dart';
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

  Future<void> removeAvatar();

  Future<void> updateIdentity({
    required String firstName,
    required String lastName,
    required String nationalId,
    required BirthDate birthDate,
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
  /// اسم الحقل `image` — مؤكّد من الباك اند، لا تبدّله لـ`avatar`
  /// «تصحيحاً» لأن هيك بتوقع الميزة بصمت.
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

  /// نفس مسار الرفع بحقل `image` فاضي — لا `null`: `multipart/form-data`
  /// ما بيحمل قيمة فاضية أصلاً غير نص فاضي.
  ///
  /// ⚠️ **افتراض غير مؤكّد**: إن الباك اند بيقرأ حقل نصّي فاضي باسم
  /// `image` كـ«امسح الصورة الحالية». ما في مثال استجابة حقيقي لهالحالة
  /// بعد — لو ما اشتغل، هون نقطة التصحيح الوحيدة.
  @override
  Future<void> removeAvatar() async {
    final formData = FormData.fromMap({_avatarField: ''});

    await _apiClient.request(
      endpoint: ApiEndpoints.profileUpdate,
      method: ApiMethod.post,
      data: formData,
    );
  }

  /// نفس مسار الصورة، بحقول الهوية بدل `image`.
  ///
  /// ⚠️ **أسماء الحقول موروثة من عقد `/api/auth/register` المؤكّد**، مش
  /// مؤكّدة بشكل مستقل لهالمسار. `birth_date` بصيغة `YYYY/M/D` — نفس
  /// صيغة الإرسال بالتسجيل، **لا** صيغة `YYYY-MM-DD` يلي بيرجّعها
  /// `GET /api/profile` (الصيغتان مختلفتان، راجع تعليق `AuthUser`).
  @override
  Future<void> updateIdentity({
    required String firstName,
    required String lastName,
    required String nationalId,
    required BirthDate birthDate,
  }) async {
    final formData = FormData.fromMap({
      'first_name': firstName,
      'last_name': lastName,
      'national_id': nationalId,
      'birth_date': birthDate.apiFormat,
    });

    await _apiClient.request(
      endpoint: ApiEndpoints.profileUpdate,
      method: ApiMethod.post,
      data: formData,
    );
  }

  /// اسم الحقل كما بينتظره `POST /api/profile/update`.
  static const String _avatarField = 'image';

  /// الرابط ممكن يرجع بالجذر أو تحت `data` أو ما يرجع أبداً. `null`
  /// نتيجة صحيحة: الواجهة أصلاً بتعرض الملف المحلي بعد الرفع.
  static String? _readAvatarUrl(dynamic response) {
    final json = response is Map ? Map<String, dynamic>.from(response) : null;

    if (json == null) return null;

    final data = json[ApiResponseKeys.data];
    final container = data is Map ? Map<String, dynamic>.from(data) : json;

    // `image` أولاً: هيك بيسمّي الباك اند الحقل بالإرسال، فالأرجح إنه
    // نفس التسمية بالاستجابة.
    for (final key in ['image', 'image_url', 'avatar_url', 'avatar', 'url']) {
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
