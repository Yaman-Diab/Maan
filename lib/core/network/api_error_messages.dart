// -------------------------
// API Error Messages
// -------------------------

import 'package:dio/dio.dart';

import 'api_error_codes.dart';
import 'api_status_codes.dart';

class ApiErrorMessages {
  ApiErrorMessages._();

  static String getUserFriendlyMessage({
    required int? statusCode,
    String? errorCode,
    DioExceptionType? dioExceptionType,
    String? fallbackMessage,
  }) {
    if (_isConnectionError(dioExceptionType)) {
      return 'تعذر الاتصال بالخادم، تحقق من الإنترنت وحاول مرة أخرى';
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
        return 'رقم الهاتف أو كلمة المرور غير صحيحة';

      case ApiErrorCodes.inactiveAccount:
        return 'هذا الحساب غير مفعّل';

      case ApiErrorCodes.invalidToken:
        return 'الجلسة غير صالحة، يرجى تسجيل الدخول مرة أخرى';

      case ApiErrorCodes.tokenNotValid:
        return 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى';

      // -------------------------
      // Validation
      // -------------------------

      case ApiErrorCodes.validationError:
        return fallbackMessage ?? 'يرجى التحقق من البيانات المدخلة';

      // -------------------------
      // OTP
      // -------------------------

      case ApiErrorCodes.otpInvalid:
        return 'رمز التحقق غير صحيح';

      case ApiErrorCodes.otpExpired:
        return 'انتهت صلاحية رمز التحقق، اطلب رمزًا جديدًا';

      case ApiErrorCodes.otpMaxAttempts:
        return 'تم تجاوز عدد المحاولات المسموح، اطلب رمزًا جديدًا';

      case ApiErrorCodes.otpRateLimited:
        return fallbackMessage ?? 'يرجى الانتظار قليلًا قبل طلب رمز جديد';

      case ApiErrorCodes.otpDeliveryFailed:
        return 'تعذر إرسال رمز التحقق، حاول مرة أخرى';

      // -------------------------
      // User
      // -------------------------

      case ApiErrorCodes.userNotFound:
        return 'لم يتم العثور على المستخدم';

      // -------------------------
      // Google
      // -------------------------

      case ApiErrorCodes.googleInvalidToken:
        return 'تعذر التحقق من حساب Google';

      case ApiErrorCodes.googleNotConfigured:
        return 'تسجيل الدخول عبر Google غير مفعّل حاليًا';

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
        return fallbackMessage ?? 'البيانات المدخلة غير صحيحة';

      case ApiStatusCodes.unauthorized:
        return 'يرجى تسجيل الدخول للمتابعة';

      case ApiStatusCodes.forbidden:
        return 'ليس لديك صلاحية لتنفيذ هذا الإجراء';

      case ApiStatusCodes.notFound:
        return 'العنصر المطلوب غير موجود';

      case ApiStatusCodes.gone:
        return 'انتهت صلاحية هذا الطلب';

      case ApiStatusCodes.tooManyRequests:
        return 'تمت محاولات كثيرة، يرجى الانتظار قليلًا';

      case ApiStatusCodes.internalServerError:
        return 'حدث خطأ في الخادم، يرجى المحاولة لاحقًا';

      case ApiStatusCodes.serviceUnavailable:
        return 'الخدمة غير متاحة حاليًا، يرجى المحاولة لاحقًا';

      default:
        return fallbackMessage ?? 'حدث خطأ غير متوقع';
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
