// -------------------------
// Login Response Model
// -------------------------

import '../../../../core/network/api_response_keys.dart';
import '../../domain/entities/auth_session.dart';
import 'auth_user_model.dart';

/// قراءة استجابة تسجيل الدخول الحقيقية وتحويلها لكيان [AuthSession].
///
/// شكل الاستجابة الفعلي (مغلّف تحت `data` زي باقي الـ endpoints):
/// ```json
/// {"status":1,"data":{"id":1,"first_name":"...","token":"eyJ...","token_type":"Bearer",...}}
/// ```
/// توكن واحد (`token`) لا زوج `access`/`refresh`، وحقول المستخدم بجذر
/// `data` مباشرة لا تحت مفتاح `user` متداخل.
class LoginResponseModel {
  final String accessToken;
  final AuthUserModel user;

  const LoginResponseModel({required this.accessToken, required this.user});

  factory LoginResponseModel.fromMap(Map<String, dynamic> json) {
    final data = _normalizeResponseData(json);

    final token = data[ApiResponseKeys.token] as String?;

    if (token == null || token.isEmpty) {
      throw const FormatException('Login response is missing a token.');
    }

    return LoginResponseModel(
      accessToken: token,
      user: AuthUserModel.fromMap(data),
    );
  }

  AuthSession toEntity() {
    return AuthSession(accessToken: accessToken, user: user.toEntity());
  }

  static Map<String, dynamic> _normalizeResponseData(
    Map<String, dynamic> json,
  ) {
    if (json.containsKey(ApiResponseKeys.token)) {
      return json;
    }

    if (json[ApiResponseKeys.data] is Map) {
      return Map<String, dynamic>.from(json[ApiResponseKeys.data] as Map);
    }

    return json;
  }

  @override
  String toString() =>
      'LoginResponseModel(accessToken: [REDACTED], user: $user)';
}
