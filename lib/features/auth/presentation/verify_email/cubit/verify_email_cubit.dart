// -------------------------
// Verify Email Cubit
// -------------------------

import '../../../../../core/result/result.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/resend_verification_usecase.dart';
import '../../verification_code/cubit/verification_code_cubit.dart';

/// تأكيد البريد بعد إنشاء الحساب.
///
/// كل المنطق بـ[VerificationCodeCubit]؛ اللي بيخصّ هالتدفّق إعادة
/// الإرسال فقط — الـ backend بيعرف المستخدم من الجلسة فما بتاخد بريد.
class VerifyEmailCubit extends VerificationCodeCubit {
  final ResendVerificationUseCase _resendVerificationUseCase;

  VerifyEmailCubit(
    super.checkCodeUseCase,
    this._resendVerificationUseCase, {
    required super.email,
    super.codeLength,
    super.cooldownSeconds,
  });

  @override
  Future<Result<void>> performResend() {
    return _resendVerificationUseCase(const NoParams());
  }
}
