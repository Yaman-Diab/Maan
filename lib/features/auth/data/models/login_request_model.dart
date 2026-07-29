// -------------------------
// Login Request Model
// -------------------------

/// شكل جسم طلب تسجيل الدخول كما بيتوقعه الـ backend.
///
/// مفاتيح الـ JSON بتبقى محصورة بطبقة الـ data — الـ domain بيتعامل
/// مع `email` و`password` كوسائط عادية.
class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {'email': email, 'password': password};
  }
}
