// -------------------------
// Route Arguments
// -------------------------

/// وسائط شاشة كلمة المرور الجديدة.
///
/// بتنمرّر عبر `GoRouterState.extra` لا عبر الـ query params — رمز
/// إعادة التعيين والبريد بيانات حساسة، وما بدنا إياها بالـ URL
/// (خصوصاً على الويب حيث بتتخزّن بسجل المتصفح).
class PasswordResetArgs {
  final String email;

  /// الرمز **بعد** ما يأكّده السيرفر بشاشة `verify_reset_code`.
  ///
  /// مطلوب لا اختياري: كان إله قيمة افتراضية فاضية، فكان بيمرّ فاضي
  /// لحد `POST /api/auth/resetPassword` وبيرجع
  /// `{"errors":{"code":["The code field is required."]}}`. خلّيه
  /// `required` حتى المترجم يمسك النقص بدل السيرفر.
  final String code;

  const PasswordResetArgs({required this.email, required this.code});
}
