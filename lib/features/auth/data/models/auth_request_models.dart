// -------------------------
// Auth Request Models
// -------------------------

/// أجسام طلبات المصادقة.
///
/// مفاتيح الـ JSON محصورة هون؛ الـ domain بيتعامل بوسائط مسمّاة.
class RegisterRequestModel {
  final String firstName;
  final String lastName;

  /// بصيغة `YYYY-MM-DD` — بتجي جاهزة من `BirthDate.formatted`.
  final String birthday;

  final String email;
  final String password;

  const RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.birthday,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'birthday': birthday,
      'email': email,
      'password': password,
    };
  }
}

class VerifyOtpRequestModel {
  final String email;
  final String code;

  const VerifyOtpRequestModel({required this.email, required this.code});

  Map<String, dynamic> toMap() => {'email': email, 'code': code};
}

class ResendOtpRequestModel {
  final String email;

  const ResendOtpRequestModel({required this.email});

  Map<String, dynamic> toMap() => {'email': email};
}

class RequestPasswordResetRequestModel {
  final String email;

  const RequestPasswordResetRequestModel({required this.email});

  Map<String, dynamic> toMap() => {'email': email};
}

class ResetPasswordRequestModel {
  final String email;
  final String code;
  final String password;

  const ResetPasswordRequestModel({
    required this.email,
    required this.code,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {'email': email, 'code': code, 'password': password};
  }
}
