// -------------------------
// Login State
// -------------------------

import 'package:equatable/equatable.dart';

enum LoginStatus { initial, submitting, success, failure }

/// حالة شاشة تسجيل الدخول.
///
/// بتحمل قيم الحقول كنصوص لا كـ `TextEditingController`، فبتقدر
/// تتّختبر بدون widget tree. الـ controllers بتضل مسؤولية الصفحة.
final class LoginState extends Equatable {
  final LoginStatus status;
  final String email;
  final String password;
  final bool isTermsAccepted;

  /// بتتفعّل بعد أول ضغطة إرسال لتشغيل التحقق التلقائي للحقول.
  final bool hasTriedSubmit;

  final String? errorMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.email = '',
    this.password = '',
    this.isTermsAccepted = false,
    this.hasTriedSubmit = false,
    this.errorMessage,
  });

  bool get isSubmitting => status == LoginStatus.submitting;

  bool get canSubmit {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        isTermsAccepted &&
        !isSubmitting;
  }

  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? password,
    bool? isTermsAccepted,
    bool? hasTriedSubmit,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isTermsAccepted: isTermsAccepted ?? this.isTermsAccepted,
      hasTriedSubmit: hasTriedSubmit ?? this.hasTriedSubmit,
      // رسالة الخطأ ما بتُورَّث: كل حالة جديدة بتصرّح فيها لو بدها إياها،
      // فما بتعلق سناك بار قديمة على حالة جديدة.
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    email,
    password,
    isTermsAccepted,
    hasTriedSubmit,
    errorMessage,
  ];
}
