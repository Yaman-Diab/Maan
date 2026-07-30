// -------------------------
// Failure Mapper
// -------------------------

import 'package:easy_localization/easy_localization.dart';

import '../network/api_error_codes.dart';
import '../network/api_exception.dart';
import '../network/api_response_keys.dart';
import '../network/api_status_codes.dart';
import 'failure.dart';

/// الحدّ الفاصل بين طبقة الشبكة وطبقة الـ domain.
///
/// كل `AuthRepositoryImpl` وأخواتها بتمسك [ApiException] وبتمرره من هون،
/// فبتطلع [Failure] ما بتحمل أي أثر لـ Dio.
///
/// الرسائل مش مكتوبة هون: مصدرها `ApiException.userMessage` اللي بيبنيها
/// `ApiErrorMessages` — وظيفة هذا الـ mapper التصنيف فقط.
class FailureMapper {
  FailureMapper._();

  /// نقطة الدخول العامة: بتتعامل مع أي استثناء، مش بس [ApiException].
  static Failure fromError(Object error) {
    if (error is ApiException) {
      return fromApiException(error);
    }

    if (error is FormatException) {
      return UnknownFailure('error_unreadable_response'.tr());
    }

    return UnknownFailure('error_unknown'.tr());
  }

  static Failure fromApiException(ApiException exception) {
    final message = exception.userMessage;
    final code = exception.errorCode;

    // كود الخطأ أدق من رمز الحالة، فبنجرّبه أولاً.
    final fromCode = _fromErrorCode(code, message);
    if (fromCode != null) {
      return fromCode;
    }

    return _fromStatusCode(exception, message, code);
  }

  // -------------------------
  // Error Code Classification
  // -------------------------

  static Failure? _fromErrorCode(String? code, String message) {
    switch (code) {
      case ApiErrorCodes.otpInvalid:
      case ApiErrorCodes.otpExpired:
      case ApiErrorCodes.otpMaxAttempts:
      case ApiErrorCodes.otpRateLimited:
      case ApiErrorCodes.otpDeliveryFailed:
        return OtpFailure(message, code: code);

      case ApiErrorCodes.invalidCredentials:
      case ApiErrorCodes.inactiveAccount:
      case ApiErrorCodes.invalidToken:
      case ApiErrorCodes.tokenNotValid:
      case ApiErrorCodes.googleInvalidToken:
      case ApiErrorCodes.userNotFound:
        return AuthFailure(message, code: code);

      case ApiErrorCodes.googleNotConfigured:
        return ServerFailure(message, code: code);

      default:
        // validationError بيمرّ من هون ليلتقط أخطاء الحقول مع رمز الحالة.
        return null;
    }
  }

  // -------------------------
  // Status Code Classification
  // -------------------------

  static Failure _fromStatusCode(
    ApiException exception,
    String message,
    String? code,
  ) {
    final statusCode = exception.statusCode;

    // ما في رمز حالة يعني الطلب ما وصل للسيرفر أصلاً (انقطاع أو مهلة).
    if (statusCode == null) {
      return NetworkFailure(message, code: code);
    }

    if (ApiStatusCodes.isUnauthorized(statusCode) ||
        statusCode == ApiStatusCodes.forbidden) {
      return AuthFailure(message, code: code);
    }

    if (statusCode == ApiStatusCodes.badRequest) {
      return ValidationFailure(
        message,
        code: code,
        fieldErrors: _extractFieldErrors(exception.data),
      );
    }

    if (statusCode == ApiStatusCodes.tooManyRequests) {
      return RateLimitFailure(message, code: code);
    }

    if (statusCode >= ApiStatusCodes.internalServerError) {
      return ServerFailure(message, code: code);
    }

    return UnknownFailure(message, code: code);
  }

  // -------------------------
  // Field Errors Extractor
  // -------------------------

  /// بيقرأ الشكل `{"errors": {"email": ["..."], "password": ["..."]}}`
  /// وبيرجّع `null` لو الشكل مختلف — الرسالة العامة بتبقى كافية وقتها.
  static Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is! Map) {
      return null;
    }

    final errors = data[ApiResponseKeys.errors];
    if (errors is! Map || errors.isEmpty) {
      return null;
    }

    final result = <String, List<String>>{};

    errors.forEach((key, value) {
      final field = key.toString();

      if (value is List) {
        result[field] = value.map((e) => e.toString()).toList();
      } else if (value != null) {
        result[field] = [value.toString()];
      }
    });

    return result.isEmpty ? null : result;
  }
}
