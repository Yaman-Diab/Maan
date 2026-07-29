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
  final String code;

  const PasswordResetArgs({required this.email, this.code = ''});
}
