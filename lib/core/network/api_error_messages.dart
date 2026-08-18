// -------------------------
// API Error Messages
// -------------------------

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import 'api_error_codes.dart';
import 'api_status_codes.dart';

/// هاي الطبقة الوحيدة اللي بتحوّل استجابة الشبكة لنص جاهز للعرض.
///
/// كل رسالة بترجع عبر `.tr()` بدل نص عربي ثابت، حتى تتبع لغة التطبيق
/// الحالية بدل ما تظهر بالعربي دائماً حتى لو المستخدم مبدّل لإنجليزي.
class ApiErrorMessages {
  ApiErrorMessages._();

  static String getUserFriendlyMessage({
    required int? statusCode,
    String? errorCode,
    DioExceptionType? dioExceptionType,
    String? fallbackMessage,
  }) {
    if (_isConnectionError(dioExceptionType)) {
      return 'error_connection'.tr();
    }

    final messageFromErrorCode = _messageFromErrorCode(
      errorCode,
      fallbackMessage: fallbackMessage,
    );

    if (messageFromErrorCode != null) {
      return messageFromErrorCode;
    }

    return _messageFromStatusCode(statusCode, fallbackMessage: fallbackMessage);
  }

  // -------------------------
  // Error Code Messages
  // -------------------------

  static String? _messageFromErrorCode(
    String? errorCode, {
    String? fallbackMessage,
  }) {
    switch (errorCode) {
      // -------------------------
      // Auth
      // -------------------------

      case ApiErrorCodes.invalidCredentials:
        return 'error_invalid_credentials'.tr();

      case ApiErrorCodes.inactiveAccount:
        return 'error_inactive_account'.tr();

      case ApiErrorCodes.invalidToken:
        return 'error_invalid_session'.tr();

      case ApiErrorCodes.tokenNotValid:
        return 'error_session_expired'.tr();

      // -------------------------
      // Validation
      // -------------------------

      case ApiErrorCodes.validationError:
        return fallbackMessage ?? 'error_validation_generic'.tr();

      // -------------------------
      // OTP
      // -------------------------

      case ApiErrorCodes.otpInvalid:
        return 'error_otp_invalid'.tr();

      case ApiErrorCodes.otpExpired:
        return 'error_otp_expired'.tr();

      case ApiErrorCodes.otpMaxAttempts:
        return 'error_otp_max_attempts'.tr();

      case ApiErrorCodes.otpRateLimited:
        return fallbackMessage ?? 'error_otp_rate_limited'.tr();

      case ApiErrorCodes.otpDeliveryFailed:
        return 'error_otp_delivery_failed'.tr();

      // -------------------------
      // User
      // -------------------------

      case ApiErrorCodes.userNotFound:
        return 'error_user_not_found'.tr();

      // -------------------------
      // Google
      // -------------------------

      case ApiErrorCodes.googleInvalidToken:
        return 'error_google_invalid_token'.tr();

      case ApiErrorCodes.googleNotConfigured:
        return 'error_google_not_configured'.tr();

      default:
        return null;
    }
  }

  // -------------------------
  // Status Code Messages
  // -------------------------

  static String _messageFromStatusCode(
    int? statusCode, {
    String? fallbackMessage,
  }) {
    switch (statusCode) {
      case ApiStatusCodes.badRequest:
      case ApiStatusCodes.unprocessableEntity:
        return fallbackMessage ?? 'error_bad_request'.tr();

      case ApiStatusCodes.unauthorized:
        return 'error_unauthorized'.tr();

      case ApiStatusCodes.forbidden:
        return 'error_forbidden'.tr();

      case ApiStatusCodes.notFound:
        return 'error_not_found'.tr();

      // ⚠️ **رسالة الباك اند هون نص جاهز للعرض لكن إنجليزي دائماً**
      // (مثلاً "You have already voted on this complaint") — استخدامه
      // كـ`fallbackMessage` كان رح يعرض إنجليزي لمستخدم عربي بغض النظر
      // عن لغة التطبيق. رسالة عامة مترجَمة بدل الرسالة الخام، نفس نمط
      // باقي رموز الحالة هون.
      case ApiStatusCodes.conflict:
        return 'error_conflict'.tr();

      case ApiStatusCodes.gone:
        return 'error_gone'.tr();

      case ApiStatusCodes.tooManyRequests:
        return 'error_too_many_requests'.tr();

      case ApiStatusCodes.internalServerError:
        return 'error_server'.tr();

      case ApiStatusCodes.serviceUnavailable:
        return 'error_service_unavailable'.tr();

      default:
        return fallbackMessage ?? 'error_unknown'.tr();
    }
  }

  // -------------------------
  // Connection Errors
  // -------------------------

  static bool _isConnectionError(DioExceptionType? type) {
    return type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.connectionError;
  }
}
