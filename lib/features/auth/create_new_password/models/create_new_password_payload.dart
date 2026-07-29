class CreateNewPasswordPayload {
  const CreateNewPasswordPayload({
    required this.password,
    required this.confirmPassword,
  });

  final String password;
  final String confirmPassword;

  Map<String, dynamic> toMap() {
    return {
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  @override
  String toString() => toMap().toString();
}
