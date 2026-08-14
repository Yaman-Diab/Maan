// -------------------------
// Token Refresh Service
// -------------------------

import 'package:dio/dio.dart';

import '../network/api_endpoints.dart';
import '../network/api_envelope.dart';
import '../network/api_request_flags.dart';
import '../network/api_response_keys.dart';
import '../storage/secure_storage_service.dart';

class TokenRefreshException implements Exception {
  final String message;

  const TokenRefreshException(this.message);

  @override
  String toString() => message;
}

/// تجديد توكن الدخول — طراز `tymon/jwt-auth` المؤكّد من رد حقيقي على
/// `/api/auth/refresh`: توكن JWT واحد بيتجدّد بإعادة إرسال **نفس
/// التوكن الحالي** عبر هيدر `Authorization` (`AuthInterceptor.onRequest`
/// بيرفقه تلقائياً — هالسيرفيس بس بيتأكّد إنه موجود قبل المحاولة).
/// **بلا `refresh_token` منفصل بالجسم** — لا جسم إرسال أصلاً.
///
/// الرد الناجح: `{"status":1,"data":{"token":"...","token_type":"Bearer"}}`.
/// ثلاث حالات فشل حقيقية موثّقة (لوغ فعلي):
/// * `{"status":1,"message":"Token not provided","data":null}` — لاحظ
///   `status:1` رغم إنه فشل؛ `ApiEnvelope` ما بتلتقطها (محافظة عمداً
///   عالفحص الصريح). الحماية الحقيقية هون: أي رد بلا `data.token` صريح
///   بيترفض بغض النظر عن `status`.
/// * `{"status":0,"message":"Wrong number of segments",...}` — توكن
///   مشوَّه.
/// * `{"status":0,"message":"Could not decode token: ...",...}` — نفس
///   الفكرة.
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
    final currentToken = await storage.getAccessToken();

    if (currentToken == null || currentToken.isEmpty) {
      throw const TokenRefreshException('No token to refresh');
    }

    try {
      final response = await dio.post(
        ApiEndpoints.refresh,
        // `skipAuthRefresh` بس — بعكس النسخة القديمة، الهيدر لازم
        // يترفق (هو أصلاً سبب فشل "Token not provided" لو انقطع).
        options: Options(extra: {ApiRequestFlags.skipAuthRefresh: true}),
      );

      final newToken = _parseToken(response.data);

      await storage.saveAccessToken(newToken);
    } on DioException catch (exception) {
      final message = _extractMessage(exception.response?.data);

      throw TokenRefreshException(message ?? 'Unable to refresh token');
    }
  }

  String _parseToken(dynamic data) {
    if (ApiEnvelope.indicatesFailure(data)) {
      throw TokenRefreshException(
        _extractMessage(data) ?? 'Refresh token failed',
      );
    }

    final json = _asMap(data);
    final payload = json[ApiResponseKeys.data];
    final token = _asMap(payload)[ApiResponseKeys.token] as String?;

    if (token == null || token.isEmpty) {
      throw TokenRefreshException(
        _extractMessage(data) ?? 'Refresh response does not contain a token',
      );
    }

    return token;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw const TokenRefreshException('Invalid refresh response format');
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) return data[ApiResponseKeys.message] as String?;

    return null;
  }
}
