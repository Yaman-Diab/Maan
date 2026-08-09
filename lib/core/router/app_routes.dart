// -------------------------
// App Routes
// -------------------------

abstract final class AppRoutes {
  // -------------------------
  // Startup / Auth
  // -------------------------

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';

  /// تأكيد رمز الاستعادة — بين `forgotPassword` و`createNewPassword`.
  static const String verifyResetCode = '/verify-reset-code';

  static const String createNewPassword = '/create-new-password';

  // --------redirect-----------------
  // Main Tabs
  // -------------------------

  static const String home = '/home';
  static const String profile = '/profile';

  /// تعديل بيانات الهوية — فرعي عن `profile`، بتوصلها `AuthUser` كامل
  /// عبر `extra` لتعبئة الحقول.
  static const String editIdentity = '/profile/edit-identity';

  /// تفضيلات التطبيق — فرعي عن `profile`، مدخلها الوحيد أيقونة الترس
  /// بشريط الملف الشخصي.
  static const String settings = '/profile/settings';

  /// توثيق الهوية — فرعي عن `profile` متل `editIdentity`.
  ///
  /// بلا وسائط: الشاشة بتسأل `GET /api/verification` بنفسها عن حالة
  /// الطلب الحالي بدل ما تستقبلها، فأي مدخل (البروفايل، إشعار، رابط
  /// عميق) بيوصل لنفس النتيجة الصحيحة.
  ///
  /// ⚠️ **مش بـ`verifiedOnlyRoutes`** — بالعكس تماماً: هي الشاشة اللي
  /// بتخلّي المستخدم يصير موثّقاً، فحجبها عن غير الموثّق بيقفل الباب
  /// اللي هي نفسها مفتاحه.
  static const String verification = '/profile/verification';

  /// الشهادات والمهارات — فرعي عن `profile` متل الباقي.
  ///
  /// ⏳ **صفحة تجريبية مؤقّتة (`_TempPage`) لحد الآن** — البانر بالملف
  /// الشخصي جاهز وبينقل للمسار، بس الشاشة الحقيقية لسه ما انبنت.
  static const String certificatesAndSkills = '/profile/certificates-skills';
}
