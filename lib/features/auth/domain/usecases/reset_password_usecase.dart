// -------------------------
// Reset Password Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

final class ResetPasswordParams extends Equatable {
  final String code;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordParams({
    required this.code,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [code, password, passwordConfirmation];
}

class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository _authRepository;

  const ResetPasswordUseCase(this._authRepository);

  /// تطابق الكلمتين تحقّق واجهة أصلاً (`AppValidators.confirmPasswordValidator`)
  /// ومترجم بـ`passwords_do_not_match` — الفورم بيمنع الإرسال قبل ما توصل
  /// هون، فتكرار الفحص هون بس بيعني نص عربي إضافي بلا ترجمة إنجليزية.
  @override
  Future<Result<void>> call(ResetPasswordParams params) {
    return _authRepository.resetPassword(
      code: params.code,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
  }
}
