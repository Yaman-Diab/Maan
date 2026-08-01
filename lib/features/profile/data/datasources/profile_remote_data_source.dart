// -------------------------
// Profile Remote Data Source
// -------------------------

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/citizen_profile_model.dart';

/// المكان الوحيد اللي بيعرف الـ endpoint داخل ميزة profile.
///
/// بيرمي `ApiException` كما هي — تحويلها لـ`Failure` مسؤولية
/// `ProfileRepositoryImpl`.
abstract class ProfileRemoteDataSource {
  Future<CitizenProfileModel> getProfile();
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

  static Map<String, dynamic> _asJsonMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);

    throw const FormatException('Unexpected response format');
  }
}
