// -------------------------
// Token Refresh Service
// -------------------------

import 'package:dio/dio.dart';

import '../network/api_endpoints.dart';
import '../network/api_error_codes.dart';
import '../network/api_request_flags.dart';
import '../network/api_response_keys.dart';
import '../network/api_status_codes.dart';
import '../storage/secure_storage_service.dart';

class TokenPair {
  final String accessToken;
  final String refreshToken;

  const TokenPair({required this.accessToken, required this.refreshToken});
}

class TokenRefreshException implements Exception {
  final String message;

  const TokenRefreshException(this.message);

  @override
  String toString() => message;
}

class TokenRefreshService {
  final Dio dio;
  final SecureStorageService storage;

  Future<void>? _refreshFuture;

  TokenRefreshService({required this.dio, required this.storage});

  Future<void> refreshTokenIfNeeded() async {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    _refreshFuture = _refreshToken();

    try {
      await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<void> _refreshToken() async {
    final currentRefreshToken = await storage.getRefreshToken();

    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      throw const TokenRefreshException('Refresh token not found');
    }

    try {
      final response = await dio.post(
        ApiEndpoints.refresh,
        data: {ApiResponseKeys.refresh: currentRefreshToken},
        options: Options(
          extra: {
            ApiRequestFlags.skipAuthHeader: true,
            ApiRequestFlags.skipAuthRefresh: true,
          },
        ),
      );

      if (!ApiStatusCodes.isSuccess(response.statusCode)) {
        throw const TokenRefreshException('Refresh token failed');
      }

      final tokenPair = _parseTokenPair(response.data);

      await storage.saveTokens(
        accessToken: tokenPair.accessToken,
        refreshToken: tokenPair.refreshToken,
      );
    } on DioException catch (exception) {
      final code = _extractErrorCode(exception.response?.data);

      if (code == ApiErrorCodes.tokenNotValid) {
        throw const TokenRefreshException(
          'Refresh token is invalid or expired',
        );
      }

      throw const TokenRefreshException('Unable to refresh token');
    }
  }

  TokenPair _parseTokenPair(dynamic data) {
    final json = _asMap(data);

    final accessToken = json[ApiResponseKeys.access] as String?;
    final refreshToken = json[ApiResponseKeys.refresh] as String?;

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw const TokenRefreshException(
        'Refresh response does not contain tokens',
      );
    }

    return TokenPair(accessToken: accessToken, refreshToken: refreshToken);
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw const TokenRefreshException('Invalid refresh response format');
  }

  String? _extractErrorCode(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data[ApiResponseKeys.code] as String?;
    }

    return null;
  }
}
