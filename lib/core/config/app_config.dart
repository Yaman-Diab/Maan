// -------------------------
// App Config
// -------------------------

class AppConfig {
  AppConfig._();

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://187-127-71-164.sslip.io',
  );

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);
}
