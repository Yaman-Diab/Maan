// -------------------------
// API Error Codes
// -------------------------

class ApiErrorCodes {
  ApiErrorCodes._();

  // Auth
  static const String invalidCredentials = 'invalid_credentials';
  static const String inactiveAccount = 'inactive_account';
  static const String invalidToken = 'invalid_token';
  static const String tokenNotValid = 'token_not_valid';

  // Validation
  static const String validationError = 'validation_error';

  // OTP
  static const String otpInvalid = 'otp_invalid';
  static const String otpExpired = 'otp_expired';
  static const String otpMaxAttempts = 'otp_max_attempts';
  static const String otpRateLimited = 'otp_rate_limited';
  static const String otpDeliveryFailed = 'otp_delivery_failed';

  // User
  static const String userNotFound = 'user_not_found';

  // Google
  static const String googleInvalidToken = 'google_invalid_token';
  static const String googleNotConfigured = 'google_not_configured';
}
