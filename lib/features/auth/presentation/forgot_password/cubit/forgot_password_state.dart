// -------------------------
// Forgot Password State
// -------------------------

import 'package:equatable/equatable.dart';

enum ForgotPasswordStatus { initial, submitting, success, failure }

final class ForgotPasswordState extends Equatable {
  final ForgotPasswordStatus status;
  final String email;
  final bool hasTriedSubmit;
  final String? errorMessage;

  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.initial,
    this.email = '',
    this.hasTriedSubmit = false,
    this.errorMessage,
  });

  bool get isSubmitting => status == ForgotPasswordStatus.submitting;

  bool get canSubmit => email.isNotEmpty && !isSubmitting;

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? email,
    bool? hasTriedSubmit,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      hasTriedSubmit: hasTriedSubmit ?? this.hasTriedSubmit,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, email, hasTriedSubmit, errorMessage];
}
