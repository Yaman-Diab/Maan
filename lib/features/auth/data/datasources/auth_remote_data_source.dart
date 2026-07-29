// -------------------------
// Auth Remote Data Source
// -------------------------

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_request_flags.dart';
import '../models/auth_request_models.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

/// المكان الوحيد اللي بيعرف Dio والـ endpoints داخل ميزة auth.
///
/// بيرمي `ApiException` كما هي — تحويلها لـ `Failure` مسؤولية
/// `AuthRepositoryImpl`.
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);

  Future<void> register(RegisterRequestModel request);

  Future<void> checkCode(CheckCodeRequestModel request);

  Future<void> resendVerification();

  Future<void> forgetPassword(ForgetPasswordRequestModel request);

  Future<void> resetPassword(ResetPasswordRequestModel request);
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
      options: _publicEndpointOptions,
    );

    return LoginResponseModel.fromMap(_asJsonMap(response));
  }

  @override
  Future<void> register(RegisterRequestModel request) async {
    await _apiClient.request(
      endpoint: ApiEndpoints.register,
      method: ApiMethod.post,
      data: request.toMap(),
      options: _publicEndpointOptions,
    );
  }

  @override
  Future<void> checkCode(CheckCodeRequestModel request) async {
    await _apiClient.request(
      endpoint: ApiEndpoints.checkCode,
      method: ApiMethod.post,
      data: request.toMap(),
      options: _publicEndpointOptions,
    );
  }

  @override
  Future<void> resendVerification() async {
    // هذا الـ endpoint مش ضمن قائمة المسارات العامة، فبيمشي بالـ
    // interceptor العادي وبينضاف عليه الـ Bearer token.
    await _apiClient.request(
      endpoint: ApiEndpoints.emailVerificationNotification,
      method: ApiMethod.post,
    );
  }

  @override
  Future<void> forgetPassword(ForgetPasswordRequestModel request) async {
    await _apiClient.request(
      endpoint: ApiEndpoints.forgetPassword,
      method: ApiMethod.post,
      data: request.toMap(),
      options: _publicEndpointOptions,
    );
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    await _apiClient.request(
      endpoint: ApiEndpoints.resetPassword,
      method: ApiMethod.post,
      data: request.toMap(),
      options: _publicEndpointOptions,
    );
  }

  // -------------------------
  // Helpers
  // -------------------------

  /// endpoints المصادقة عامة: بلا Bearer header وبلا محاولة تجديد توكن.
  static Options get _publicEndpointOptions {
    return Options(
      extra: {
        ApiRequestFlags.skipAuthHeader: true,
        ApiRequestFlags.skipAuthRefresh: true,
      },
    );
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
