// -------------------------
// Create New Password State
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../domain/entities/password_checks.dart';

enum CreateNewPasswordStatus { initial, submitting, success, failure }

final class CreateNewPasswordState extends Equatable {
  /// البريد ورمز التحقق بيجوا من شاشة "نسيت كلمة المرور".
  final String email;
  final String code;

  final CreateNewPasswordStatus status;
  final String password;
  final String confirmPassword;
  final bool hasTriedSubmit;
  final String? errorMessage;

  const CreateNewPasswordState({
    this.email = '',
    this.code = '',
    this.status = CreateNewPasswordStatus.initial,
    this.password = '',
    this.confirmPassword = '',
    this.hasTriedSubmit = false,
    this.errorMessage,
  });

  bool get isSubmitting => status == CreateNewPasswordStatus.submitting;

  bool get canSubmit {
    return password.isNotEmpty && confirmPassword.isNotEmpty && !isSubmitting;
  }

  PasswordChecks get passwordChecks => PasswordChecks.fromPassword(password);

  CreateNewPasswordState copyWith({
    CreateNewPasswordStatus? status,
    String? password,
    String? confirmPassword,
    bool? hasTriedSubmit,
    String? errorMessage,
  }) {
    return CreateNewPasswordState(
      email: email,
      code: code,
      status: status ?? this.status,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      hasTriedSubmit: hasTriedSubmit ?? this.hasTriedSubmit,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    email,
    code,
    status,
    password,
    confirmPassword,
    hasTriedSubmit,
    errorMessage,
  ];
}
