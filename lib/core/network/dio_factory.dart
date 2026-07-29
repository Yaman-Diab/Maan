// -------------------------
// Dio Factory
// -------------------------

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../session/session_manager.dart';
import '../session/token_refresh_service.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

class DioFactory {
  DioFactory._();

  static Dio create({
    required SecureStorageService storage,
    required SessionManager sessionManager,
  }) {
    final dio = Dio(_baseOptions());

    final refreshDio = Dio(_baseOptions());

    final tokenRefreshService = TokenRefreshService(
      dio: refreshDio,
      storage: storage,
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        storage: storage,
        sessionManager: sessionManager,
        tokenRefreshService: tokenRefreshService,
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );

    return dio;
  }

  static BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }
}
