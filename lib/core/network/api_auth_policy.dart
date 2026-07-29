// -------------------------
// API Auth Policy
// -------------------------

import 'api_endpoints.dart';

class ApiAuthPolicy {
  ApiAuthPolicy._();

  static const List<String> publicEndpoints = [
    ApiEndpoints.health,
    ApiEndpoints.register,
    ApiEndpoints.login,
    ApiEndpoints.otpVerify,
    ApiEndpoints.otpResend,
    ApiEndpoints.googleAuth,
    ApiEndpoints.refresh,
  ];

  static bool isPublicEndpoint(String path) {
    final normalizedPath = _normalizePath(path);

    return publicEndpoints.any((endpoint) => normalizedPath.endsWith(endpoint));
  }

  static bool isRefreshEndpoint(String path) {
    final normalizedPath = _normalizePath(path);
    return normalizedPath.endsWith(ApiEndpoints.refresh);
  }

  static bool isLogoutEndpoint(String path) {
    final normalizedPath = _normalizePath(path);
    return normalizedPath.endsWith(ApiEndpoints.logout);
  }

  static String _normalizePath(String path) {
    final uri = Uri.tryParse(path);

    if (uri == null) return path;

    if (uri.path.isNotEmpty) {
      return uri.path;
    }

    return path;
  }
}
