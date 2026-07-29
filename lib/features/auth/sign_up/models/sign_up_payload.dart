class SignUpPayload {
  const SignUpPayload({
    required this.firstName,
    required this.lastName,
    required this.birthday,
    required this.email,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String birthday;
  final String email;
  final String password;

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'birthday': birthday,
      'email': email,
      'password': password,
    };
  }

  @override
  String toString() => toMap().toString();
}
