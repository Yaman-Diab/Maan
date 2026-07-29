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

  Future<void> verifyOtp(VerifyOtpRequestModel request);

  Future<void> resendOtp(ResendOtpRequestModel request);

  Future<void> requestPasswordReset(RequestPasswordResetRequestModel request);

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
  Future<void> verifyOtp(VerifyOtpRequestModel request) async {
    await _apiClient.request(
      endpoint: ApiEndpoints.otpVerify,
      method: ApiMethod.post,
      data: request.toMap(),
      options: _publicEndpointOptions,
    );
  }

  @override
  Future<void> resendOtp(ResendOtpRequestModel request) async {
    await _apiClient.request(
      endpoint: ApiEndpoints.otpResend,
      method: ApiMethod.post,
      data: request.toMap(),
      options: _publicEndpointOptions,
    );
  }

  // -------------------------
  // Password Reset
  // -------------------------
  //
  // الـ backend لسه ما عرّف endpoints لإعادة تعيين كلمة المرور، وما في
  // ثوابت إلها بـ ApiEndpoints. الفشل صريح هون بدل ما ينضرب طلب على
  // مسار مخترَع ويرجع 404 يبان كأنه خطأ سيرفر.

  @override
  Future<void> requestPasswordReset(RequestPasswordResetRequestModel request) {
    throw UnimplementedError(
      'Password reset request endpoint is not defined by the backend yet.',
    );
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) {
    throw UnimplementedError(
      'Password reset endpoint is not defined by the backend yet.',
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
