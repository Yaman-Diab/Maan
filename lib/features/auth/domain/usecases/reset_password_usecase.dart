// -------------------------
// Reset Password Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
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

  @override
  Future<Result<void>> call(ResetPasswordParams params) async {
    // تطابق الكلمتين قاعدة عمل، مش تحقق واجهة — فبتنفّذ قبل أي طلب شبكة.
    if (params.password != params.passwordConfirmation) {
      return const Err<void>(ValidationFailure('كلمتا المرور غير متطابقتين'));
    }

    return _authRepository.resetPassword(
      code: params.code,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
  }
}
