// -------------------------
// Verification Code State
// -------------------------

import 'package:equatable/equatable.dart';

enum VerificationCodeStatus { initial, submitting, success, failure }

/// حالة مشتركة لكل شاشة بتطلب رمزاً وصل على البريد.
///
/// شاشتان بتستخدموها اليوم: تأكيد البريد بعد التسجيل، وتأكيد رمز
/// استعادة كلمة المرور. الاثنتان بتضربوا نفس `POST /api/auth/checkCode`
/// وبتعرضوا نفس الواجهة — الفرق الوحيد **إعادة الإرسال** ووين بيروح
/// المستخدم بعد النجاح، وهدول الاثنين برّا الحالة.
final class VerificationCodeState extends Equatable {
  final String email;
  final int codeLength;
  final String code;

  final VerificationCodeStatus status;
  final bool isResending;

  /// العدّ التنازلي قبل ما يُسمح بطلب رمز جديد.
  final int remainingSeconds;

  final bool isHelpVisible;

  /// خطأ بيظهر تحت خانات الرمز مباشرة.
  final String? codeError;

  /// خطأ عام بيظهر كـ SnackBar.
  final String? errorMessage;

  const VerificationCodeState({
    required this.email,
    this.codeLength = 6,
    this.code = '',
    this.status = VerificationCodeStatus.initial,
    this.isResending = false,
    this.remainingSeconds = 0,
    this.isHelpVisible = false,
    this.codeError,
    this.errorMessage,
  });

  bool get isSubmitting => status == VerificationCodeStatus.submitting;

  bool get hasCodeError => codeError != null;

  bool get canResend => remainingSeconds == 0 && !isResending;

  bool get canSubmit => code.trim().length == codeLength && !isSubmitting;

  VerificationCodeState copyWith({
    String? code,
    VerificationCodeStatus? status,
    bool? isResending,
    int? remainingSeconds,
    bool? isHelpVisible,
    String? codeError,
    String? errorMessage,
  }) {
    return VerificationCodeState(
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
