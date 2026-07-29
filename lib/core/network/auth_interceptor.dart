// -------------------------
// Auth Interceptor
// -------------------------

import 'package:dio/dio.dart';

import '../network/api_auth_policy.dart';
import '../network/api_request_flags.dart';
import '../network/api_status_codes.dart';
import '../session/session_manager.dart';
import '../session/token_refresh_service.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService storage;
  final SessionManager sessionManager;
  final TokenRefreshService tokenRefreshService;

  AuthInterceptor({
    required this.dio,
    required this.storage,
    required this.sessionManager,
    required this.tokenRefreshService,
  });

  // -------------------------
  // Request
  // -------------------------

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final shouldSkipAuthHeader =
        options.extra[ApiRequestFlags.skipAuthHeader] == true;

    final isPublicEndpoint = ApiAuthPolicy.isPublicEndpoint(options.path);

    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    final shouldAttachToken = !shouldSkipAuthHeader && !isPublicEndpoint;

    if (shouldAttachToken) {
      final accessToken = await storage.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    handler.next(options);
  }
  // -------------------------
  // Error
  // -------------------------

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final statusCode = err.response?.statusCode;
    final path = requestOptions.path;

    final isUnauthorized = ApiStatusCodes.isUnauthorized(statusCode);
    final isPublicEndpoint = ApiAuthPolicy.isPublicEndpoint(path);
    final isRefreshEndpoint = ApiAuthPolicy.isRefreshEndpoint(path);
    final isLogoutEndpoint = ApiAuthPolicy.isLogoutEndpoint(path);

    final shouldSkipAuthRefresh =
        requestOptions.extra[ApiRequestFlags.skipAuthRefresh] == true;

    final alreadyRetried =
        requestOptions.extra[ApiRequestFlags.retried] == true;

    if (!isUnauthorized) {
      handler.next(err);
      return;
    }

    // Public auth errors مثل invalid credentials أو wrong OTP
    // يجب أن ترجع للـ UI، ولا نعمل refresh أو logout.
    if (isPublicEndpoint) {
      handler.next(err);
      return;
    }

    // إذا refresh نفسه فشل، لا نحاول refresh مرة ثانية.
    if (isRefreshEndpoint || shouldSkipAuthRefresh) {
      await sessionManager.handleUnauthorized();
      handler.reject(err);
      return;
    }

    // إذا logout فشل بسبب unauthorized، نظف الجلسة محليًا.
    if (isLogoutEndpoint) {
      await sessionManager.handleUnauthorized();
      handler.reject(err);
      return;
    }

    // منع loop:
    // request → 401 → refresh → retry → 401 → logout
    if (alreadyRetried) {
      await sessionManager.handleUnauthorized();
      handler.reject(err);
      return;
    }

    try {
      await tokenRefreshService.refreshTokenIfNeeded();

      final newAccessToken = await storage.getAccessToken();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        await sessionManager.handleUnauthorized();
        handler.reject(err);
        return;
      }

      requestOptions.extra[ApiRequestFlags.retried] = true;
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      final response = await dio.fetch(requestOptions);

      handler.resolve(response);
    } catch (_) {
      await sessionManager.handleUnauthorized();
      handler.reject(err);
    }
  }
}
