// -------------------------
// Auth Remote Data Source
// -------------------------

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_request_flags.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

/// المكان الوحيد اللي بيعرف Dio والـ endpoints داخل ميزة auth.
///
/// بيرمي [ApiException] كما هي — تحويلها لـ `Failure` مسؤولية
/// `AuthRepositoryImpl`.
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await _apiClient.request(
      endpoint: ApiEndpoints.login,
      method: ApiMethod.post,
      data: request.toMap(),
      // تسجيل الدخول endpoint عام: بلا Bearer header وبلا محاولة تجديد توكن.
      options: Options(
        extra: {
          ApiRequestFlags.skipAuthHeader: true,
          ApiRequestFlags.skipAuthRefresh: true,
        },
      ),
    );

    return LoginResponseModel.fromMap(_asJsonMap(response));
  }

  /// `ApiClient.request` بيرجّع `dynamic`، فبنضيّق النوع بمكان واحد
  /// بدل ما يتكرر الفحص بكل ميثود.
  static Map<String, dynamic> _asJsonMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw const FormatException('Unexpected response format');
  }
}
