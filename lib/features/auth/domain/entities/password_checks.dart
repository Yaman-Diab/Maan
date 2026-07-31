// -------------------------
// Password Checks
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/design_system/password_policy.dart';

/// قواعد قوة كلمة المرور، بتغذّي مؤشر القواعد بالواجهة.
///
/// القواعد الخام (الأطوال والـ regex) مصدرها `PasswordPolicy` بـ`core/`
/// — نفس المصدر اللي بيبني عليه `AppValidators` رسائل الفورم. قبلها
/// كانت القواعد مكتوبة مرتين بشكل مستقل (وقبلها كمان مكررة حرفياً
/// تحت `auth/models/` و`sign_up/models/`).
final class PasswordChecks extends Equatable {
  final bool hasMinLength;
  final bool hasNumber;
  final bool hasSpecialCharacter;
  final bool hasUpperAndLowerCase;

  const PasswordChecks({
    required this.hasMinLength,
    required this.hasNumber,
    required this.hasSpecialCharacter,
    required this.hasUpperAndLowerCase,
  });

  factory PasswordChecks.empty() {
    return const PasswordChecks(
      hasMinLength: false,
      hasNumber: false,
      hasSpecialCharacter: false,
      hasUpperAndLowerCase: false,
    );
  }

  factory PasswordChecks.fromPassword(String password) {
    return PasswordChecks(
      hasMinLength: PasswordPolicy.hasMinLength(password),
      hasNumber: PasswordPolicy.hasDigit(password),
      hasSpecialCharacter: PasswordPolicy.hasSpecialCharacter(password),
      hasUpperAndLowerCase:
          PasswordPolicy.hasUppercase(password) &&
          PasswordPolicy.hasLowercase(password),
    );
  }

  bool get isStrong =>
      hasMinLength && hasNumber && hasSpecialCharacter && hasUpperAndLowerCase;

  @override
  List<Object?> get props => [
    hasMinLength,
    hasNumber,
    hasSpecialCharacter,
    hasUpperAndLowerCase,
  ];
}
