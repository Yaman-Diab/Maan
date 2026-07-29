// -------------------------
// API Exception
// -------------------------

import 'package:dio/dio.dart';

import 'api_error_messages.dart';
import 'api_response_keys.dart';

class ApiException implements Exception {
  final int? statusCode;

  /// الرسالة الأصلية القادمة من الـ backend أو من Dio.
  /// لا تعرضها دائمًا للمستخدم.
  final String message;

  /// الرسالة النظيفة المناسبة للعرض في الواجهة.
  final String userMessage;

  /// كود الخطأ القادم من الـ backend مثل token_not_valid.
  final String? errorCode;

  final dynamic data;

  const ApiException({
    required this.message,
    required this.userMessage,
    this.statusCode,
    this.errorCode,
    this.data,
  });

  factory ApiException.fromResponse(Response response) {
    final backendMessage =
        _extractMessage(response.data) ?? 'HTTP Error ${response.statusCode}';

    final errorCode = _extractErrorCode(response.data);

    return ApiException(
      statusCode: response.statusCode,
      data: response.data,
      message: backendMessage,
      errorCode: errorCode,
      userMessage: ApiErrorMessages.getUserFriendlyMessage(
        statusCode: response.statusCode,
        errorCode: errorCode,
        fallbackMessage: backendMessage,
      ),
    );
  }

  factory ApiException.fromDioException(DioException exception) {
    final response = exception.response;

    final backendMessage =
        _extractMessage(response?.data) ??
        exception.message ??
        'Unexpected network error';

    final errorCode = _extractErrorCode(response?.data);

    return ApiException(
      statusCode: response?.statusCode,
      data: response?.data,
      message: backendMessage,
      errorCode: errorCode,
      userMessage: ApiErrorMessages.getUserFriendlyMessage(
        statusCode: response?.statusCode,
        errorCode: errorCode,
        dioExceptionType: exception.type,
        fallbackMessage: backendMessage,
      ),
    );
  }

  // -------------------------
  // Message Extractor
  // -------------------------

  static String? _extractMessage(dynamic data) {
    final json = _asMapOrNull(data);

    if (json == null) {
      return null;
    }

    final message = json[ApiResponseKeys.message];
    if (message != null) {
      return message.toString();
    }

    final detail = json[ApiResponseKeys.detail];
    if (detail != null) {
      return detail.toString();
    }

    final errors = json[ApiResponseKeys.errors];

    if (errors is List && errors.isNotEmpty) {
      final firstError = errors.first;

      if (firstError is Map) {
        final errorMessage = firstError[ApiResponseKeys.message];
        if (errorMessage != null) {
          return errorMessage.toString();
        }
      }

      return firstError.toString();
    }

    if (errors is Map && errors.isNotEmpty) {
      final firstValue = errors.values.first;

      if (firstValue is List && firstValue.isNotEmpty) {
        return firstValue.first.toString();
      }

      return firstValue.toString();
    }

    return null;
  }
  // -------------------------
  // Error Code Extractor
  // -------------------------

  static String? _extractErrorCode(dynamic data) {
    final json = _asMapOrNull(data);

    if (json == null) {
      return null;
    }

    final rootCode = json[ApiResponseKeys.code];
    if (rootCode != null) {
      return rootCode.toString();
    }

    final errors = json[ApiResponseKeys.errors];

    if (errors is List && errors.isNotEmpty) {
      final firstError = errors.first;

      if (firstError is Map) {
        final code = firstError[ApiResponseKeys.code];
        return code?.toString();
      }
    }

    return null;
  }
  // -------------------------
  // Map Parser
  // -------------------------

  static Map<String, dynamic>? _asMapOrNull(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  @override
  String toString() => message;
}
