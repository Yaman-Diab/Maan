// -------------------------
// Password Policy
// -------------------------

/// قواعد قوة كلمة المرور الخام — Dart نقي بلا Flutter ولا ترجمة.
///
/// مصدر الحقيقة الوحيد لسياسة كلمة المرور. مستهلَكة من طرفين ما بينفع
/// وحدة فيهم تعتمد على التانية مباشرة:
/// - `AppValidators` (هون بـ`core/`) بيبني رسائل مترجمة فوقها لحقل الفورم.
/// - `PasswordChecks` (`features/auth/domain`) كيان domain بيستخدمها
///   لمؤشر القواعد بالواجهة.
///
/// `core` ما بتقدر تستورد من `features`، والـ domain ما بتعتمد على أداة
/// UI/ترجمة — فالقواعد الخام هون كنقطة تلاقي مسموحة للاثنين (الاتجاه
/// المسموح دائماً: feature → core). الملف بلا أي استيراد خارجي، فاستهلاك
/// domain له ما بيخالف قاعدة "الـ domain بلا Flutter/Dio".
abstract final class PasswordPolicy {
  static const int minLength = 8;

  static final RegExp _specialCharacterPattern = RegExp(
    r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]=+]',
  );

  static bool hasMinLength(String password) => password.length >= minLength;

  static bool hasDigit(String password) => RegExp(r'\d').hasMatch(password);

  static bool hasUppercase(String password) =>
      RegExp(r'[A-Z]').hasMatch(password);

  static bool hasLowercase(String password) =>
      RegExp(r'[a-z]').hasMatch(password);

  static bool hasSpecialCharacter(String password) =>
      _specialCharacterPattern.hasMatch(password);
}
