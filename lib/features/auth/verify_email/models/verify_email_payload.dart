class VerifyEmailPayload {
  const VerifyEmailPayload({
    required this.email,
    required this.code,
  });

  final String email;
  final String code;

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'code': code,
    };
  }

  @override
  String toString() => toMap().toString();
}
