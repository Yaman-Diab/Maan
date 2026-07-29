class PasswordChecks {
  const PasswordChecks({
    required this.hasMinLength,
    required this.hasNumber,
    required this.hasSpecialCharacter,
    required this.hasUpperAndLowerCase,
  });

  final bool hasMinLength;
  final bool hasNumber;
  final bool hasSpecialCharacter;
  final bool hasUpperAndLowerCase;

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
        r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]=+]',
      ).hasMatch(password),
      hasUpperAndLowerCase: RegExp(r'[A-Z]').hasMatch(password) &&
          RegExp(r'[a-z]').hasMatch(password),
    );
  }
}
