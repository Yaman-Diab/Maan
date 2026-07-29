// -------------------------
// Password Checks
// -------------------------

import 'package:equatable/equatable.dart';

/// قواعد قوة كلمة المرور، بتغذّي مؤشر القواعد بالواجهة.
///
/// كانت مكررة نسختين متطابقتين تحت `auth/models/` و`sign_up/models/`.
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
      hasMinLength: password.length >= 8,
      hasNumber: RegExp(r'[0-9]').hasMatch(password),
      hasSpecialCharacter: RegExp(
        r'[!@#\$%^&*(),.?":{}|<>_\-\\/\[\]=+]',
      ).hasMatch(password),
      hasUpperAndLowerCase:
          RegExp(r'[A-Z]').hasMatch(password) &&
          RegExp(r'[a-z]').hasMatch(password),
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
