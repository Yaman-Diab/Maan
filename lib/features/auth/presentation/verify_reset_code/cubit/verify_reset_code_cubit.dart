// -------------------------
// Verify Reset Code Cubit
// -------------------------

import '../../../../../core/result/result.dart';
import '../../../domain/usecases/forget_password_usecase.dart';
import '../../verification_code/cubit/verification_code_cubit.dart';

/// تأكيد رمز استعادة كلمة المرور — الخطوة اللي بين «نسيت كلمة المرور»
/// و«كلمة المرور الجديدة».
///
/// بلاها كان `PasswordResetArgs.code` بيوصل فاضي، فـ
/// `POST /api/auth/resetPassword` بيرجّع
/// `{"errors":{"code":["The code field is required."]}}`.
///
/// كل المنطق بـ[VerificationCodeCubit]؛ الفرق الوحيد إن إعادة الإرسال
/// بتضرب `forgetPassword` من جديد بنفس البريد — ما في endpoint مخصّص
/// لإعادة إرسال رمز الاستعادة، وإعادة طلب الاستعادة بتولّد رمزاً جديد.
///
/// ⚠️ التحقق بيمرّ على نفس `POST /api/auth/checkCode` تبع تأكيد البريد.
/// إنه يقبل رموز الاستعادة **مفترَض لا مؤكّد**، وكمان مش مؤكّد إذا
/// بيستهلك الرمز فيفشل `resetPassword` بعده. راجع `CLAUDE.md` › فجوات
/// معروفة.
class VerifyResetCodeCubit extends VerificationCodeCubit {
  final ForgetPasswordUseCase _forgetPasswordUseCase;

  VerifyResetCodeCubit(
    super.checkCodeUseCase,
    this._forgetPasswordUseCase, {
    required super.email,
    super.codeLength,
    super.cooldownSeconds,
  });

  @override
  Future<Result<void>> performResend() {
    return _forgetPasswordUseCase(ForgetPasswordParams(email: state.email));
  }
}
