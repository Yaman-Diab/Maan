// -------------------------
// Auth Request Models
// -------------------------

/// أجسام طلبات المصادقة، بمفاتيح snake_case كما هي موثّقة بـ`collection.md`.
///
/// المفاتيح محصورة بطبقة الـ data؛ الـ domain بيتعامل بوسائط مسمّاة.
class RegisterRequestModel {
  final String firstName;
  final String lastName;

  /// بصيغة `YYYY/M/D` — بتجي جاهزة من `BirthDate.apiFormat`.
  final String birthDate;

  final String nationalId;
  final String email;
  final String password;
  final String passwordConfirmation;

  const RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.nationalId,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate,
      'national_id': nationalId,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}

class CheckCodeRequestModel {
  final String code;

  const CheckCodeRequestModel({required this.code});

  Map<String, dynamic> toMap() => {'code': code};
}

class ForgetPasswordRequestModel {
  final String email;

  const ForgetPasswordRequestModel({required this.email});

  Map<String, dynamic> toMap() => {'email': email};
}

class ResetPasswordRequestModel {
  final String code;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordRequestModel({
    required this.code,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toMap() {
    return {
      'password': password,
      'password_confirmation': passwordConfirmation,
      'code': code,
    };
  }
}
