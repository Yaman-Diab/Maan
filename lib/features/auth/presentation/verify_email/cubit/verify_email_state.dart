// -------------------------
// Verify Email State
// -------------------------

import 'package:equatable/equatable.dart';

enum VerifyEmailStatus { initial, submitting, success, failure }

final class VerifyEmailState extends Equatable {
  final String email;
  final int codeLength;
  final String code;

  final VerifyEmailStatus status;
  final bool isResending;

  /// العدّ التنازلي قبل ما يُسمح بطلب رمز جديد.
  final int remainingSeconds;

  final bool isHelpVisible;

  /// خطأ بيظهر تحت خانات الرمز مباشرة.
  final String? codeError;

  /// خطأ عام بيظهر كـ SnackBar.
  final String? errorMessage;

  const VerifyEmailState({
    required this.email,
    this.codeLength = 6,
    this.code = '',
    this.status = VerifyEmailStatus.initial,
    this.isResending = false,
    this.remainingSeconds = 0,
    this.isHelpVisible = false,
    this.codeError,
    this.errorMessage,
  });

  bool get isSubmitting => status == VerifyEmailStatus.submitting;

  bool get hasCodeError => codeError != null;

  bool get canResend => remainingSeconds == 0 && !isResending;

  bool get canSubmit => code.trim().length == codeLength && !isSubmitting;

  VerifyEmailState copyWith({
    String? code,
    VerifyEmailStatus? status,
    bool? isResending,
    int? remainingSeconds,
    bool? isHelpVisible,
    String? codeError,
    String? errorMessage,
  }) {
    return VerifyEmailState(
      email: email,
      codeLength: codeLength,
      code: code ?? this.code,
      status: status ?? this.status,
      isResending: isResending ?? this.isResending,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isHelpVisible: isHelpVisible ?? this.isHelpVisible,
      // الأخطاء ما بتنورّث حتى ما تعلق رسالة قديمة على حالة جديدة.
      codeError: codeError,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    email,
    codeLength,
    code,
    status,
    isResending,
    remainingSeconds,
    isHelpVisible,
    codeError,
    errorMessage,
  ];
}
