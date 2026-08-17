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

  /// تاب ثالث بالشريط السفلي — راجع `AppRouter` لعدد فروع
  /// `StatefulShellRoute` المطلوب مطابقته.
  static const String complaints = '/complaints';

  /// تقديم شكوى جديدة — فرعي عن `complaints` بس **مش** تحت `/complaints`
  /// بالمسار (شاشة مكدّسة فوق التاب، مش تاب رابع).
  static const String submitComplaint = '/complaint/submit';

  /// تفاصيل شكوى — الكيان كامل بيوصل عبر `extra` (نفس منطق
  /// `editIdentity`)، فما في مسار GET يعيد الجلب؛ القائمة أصلاً عندها
  /// البيانات.
  static const String complaintDetail = '/complaint/detail';

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
  static const String certificatesAndSkills = '/profile/certificates-skills';

  /// تفاصيل مهارة — الكيان كامل بيوصل عبر `extra` (نفس منطق
  /// `complaintDetail`)، فما في مسار GET يعيد الجلب؛ القائمة أصلاً
  /// عندها البيانات.
  static const String skillDetail = '/profile/certificates-skills/detail';

  /// خدمات البلدية — للعرض فقط (وقت انتظار مقدّر لكل خدمة)، بلا أي
  /// علاقة بنظام الطابور الفعلي. مدخلها الحالي زر مؤقّت بـ
  /// `HomeVerificationPage` لحد ما تُبنى شاشة Home الحقيقية.
  static const String municipalServices = '/municipal-services';
}
