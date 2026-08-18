// -------------------------
// API Status Codes
// -------------------------

class ApiStatusCodes {
  ApiStatusCodes._();

  static const int ok = 200;
  static const int created = 201;

  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;

  /// تعارض حالة — مؤكّد من عقد تصويت الشكاوى (صوّت قبل هيك / ما صوّت
  /// أصلاً). راجع `ApiErrorMessages._messageFromStatusCode`.
  static const int conflict = 409;

  static const int gone = 410;

  /// رمز Laravel القياسي لأخطاء التحقق — هو اللي بيرجّعه الباك اند
  /// فعلياً، لا 400. راجع `FailureMapper._fromStatusCode`.
  static const int unprocessableEntity = 422;

  static const int tooManyRequests = 429;

  static const int redirect = 302;

  static const int internalServerError = 500;
  static const int serviceUnavailable = 503;

  static bool isSuccess(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode >= 200 && statusCode < 300;
  }

  static bool isUnauthorized(int? statusCode) {
    return statusCode == unauthorized || statusCode == redirect;
  }
}
