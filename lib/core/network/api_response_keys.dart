// -------------------------
// API Response Keys
// -------------------------

class ApiResponseKeys {
  ApiResponseKeys._();

  /// توكن دخول واحد — هيك `POST /api/auth/login` و`POST /api/auth/refresh`
  /// بيرجّعوه فعلياً، لا `access`/`refresh` زوج. راجع `AuthSession`
  /// و`TokenRefreshService`.
  static const String token = 'token';

  static const String message = 'message';
  static const String detail = 'detail';
  static const String code = 'code';

  static const String data = 'data';
  static const String errors = 'errors';
  static const String meta = 'meta';

  // -------------------------
  // Response Envelope
  // -------------------------
  //
  // الـ backend بيرجّع الفشل برمز HTTP 200 والحالة الحقيقية بالجسم،
  // وبشكلين غير متسقين: `status: 1|0` و`success: true|false`.
  // راجع `ApiEnvelope`.

  static const String status = 'status';
  static const String success = 'success';
}
