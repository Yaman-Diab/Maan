// -------------------------
// API Endpoints
// -------------------------

class ApiEndpoints {
  ApiEndpoints._();

  static const String apiV1 = '/api/v1';

  // Health
  static const String health = '$apiV1/health/';

  // Auth
  static const String login = '$apiV1/auth/login';
  static const String register = '$apiV1/auth/register';
  static const String otpVerify = '$apiV1/auth/otp/verify';
  static const String otpResend = '$apiV1/auth/otp/resend';
  static const String googleAuth = '$apiV1/auth/google';
  static const String refresh = '$apiV1/auth/refresh';
  static const String logout = '$apiV1/auth/logout';

  // Users
  static const String usersMe = '$apiV1/users/me/';
}
