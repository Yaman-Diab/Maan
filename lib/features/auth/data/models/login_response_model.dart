// -------------------------
// Login Response Model
// -------------------------

import '../../../../core/network/api_response_keys.dart';
import '../../domain/entities/auth_session.dart';

/// قراءة استجابة تسجيل الدخول وتحويلها لكيان [AuthSession].
///
/// الـ backend بيرجّع التوكنات إما بجذر الاستجابة أو تحت مفتاح `data`،
/// فـ[_normalizeResponseData] بتوحّد الشكلين قبل القراءة.
class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic>? user;

  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory LoginResponseModel.fromMap(Map<String, dynamic> json) {
    final data = _normalizeResponseData(json);

    final accessToken = data[ApiResponseKeys.access] as String?;
    final refreshToken = data[ApiResponseKeys.refresh] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      throw const FormatException('Login response is missing an access token.');
    }

    if (refreshToken == null || refreshToken.isEmpty) {
      throw const FormatException('Login response is missing a refresh token.');
    }

    final user = data[ApiResponseKeys.data] is Map
        ? Map<String, dynamic>.from(data[ApiResponseKeys.data] as Map)
        : null;

    return LoginResponseModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  AuthSession toEntity() {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  static Map<String, dynamic> _normalizeResponseData(
    Map<String, dynamic> json,
  ) {
    if (json.containsKey(ApiResponseKeys.access) &&
        json.containsKey(ApiResponseKeys.refresh)) {
      return json;
    }

    if (json[ApiResponseKeys.data] is Map) {
      return Map<String, dynamic>.from(json[ApiResponseKeys.data] as Map);
    }

    return json;
  }

  @override
  String toString() =>
      'LoginResponseModel(accessToken: [REDACTED], refreshToken: [REDACTED], user: $user)';
}
