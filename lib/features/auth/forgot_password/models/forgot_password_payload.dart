class ForgotPasswordPayload {
  const ForgotPasswordPayload({required this.email});

  final String email;

  Map<String, dynamic> toMap() {
    return {
      'email': email,
    };
  }

  @override
  String toString() => toMap().toString();
}
