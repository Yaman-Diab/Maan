// -------------------------
// API Endpoints
// -------------------------

/// مسارات الـ backend كما هي موثّقة بـ`collection.md`.
///
/// ملاحظة: ما في بادئة `v1` — المسارات تحت `/api` مباشرة.
class ApiEndpoints {
  ApiEndpoints._();

  static const String api = '/api';

  // -------------------------
  // Auth
  // -------------------------

  static const String login = '$api/auth/login';
  static const String register = '$api/auth/register';
  static const String logout = '$api/auth/logout';
  static const String refresh = '$api/auth/refresh';

  /// تأكيد رمز التحقق. الجسم بياخد `code` فقط.
  static const String checkCode = '$api/auth/checkCode';

  static const String forgetPassword = '$api/auth/forgetPassword';
  static const String resetPassword = '$api/auth/resetPassword';

  /// إعادة إرسال رسالة التحقق (اصطلاح Laravel).
  static const String emailVerificationNotification =
      '$api/email/verification-notification';
}
