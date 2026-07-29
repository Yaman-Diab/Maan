import 'package:maan/core/network/api_response_keys.dart';

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic>? user;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> json) {
    final data = _normalizeResponseData(json);

    final accessToken = data[ApiResponseKeys.access] as String?;
    final refreshToken = data[ApiResponseKeys.refresh] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      throw FormatException('Login response is missing an access token.');
    }

    if (refreshToken == null || refreshToken.isEmpty) {
      throw FormatException('Login response is missing a refresh token.');
    }

    final user = data[ApiResponseKeys.data] is Map
        ? Map<String, dynamic>.from(data[ApiResponseKeys.data] as Map)
        : null;

    return LoginResponse(
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

    if (json[ApiResponseKeys.data] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(json[ApiResponseKeys.data] as Map);
    }

    if (json[ApiResponseKeys.data] is Map) {
      return Map<String, dynamic>.from(json[ApiResponseKeys.data] as Map);
    }

    return json;
  }

  @override
  String toString() {
    return 'LoginResponse(accessToken: [REDACTED], refreshToken: [REDACTED], user: $user)';
  }
}
