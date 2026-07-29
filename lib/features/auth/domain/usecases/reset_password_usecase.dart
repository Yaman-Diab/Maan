// -------------------------
// Reset Password Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

final class ResetPasswordParams extends Equatable {
  final String email;
  final String code;
  final String password;
  final String confirmPassword;

  const ResetPasswordParams({
    required this.email,
    required this.code,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, code, password, confirmPassword];
}

class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository _authRepository;

  const ResetPasswordUseCase(this._authRepository);

  @override
  Future<Result<void>> call(ResetPasswordParams params) async {
    // تطابق الكلمتين قاعدة عمل، مش تحقق واجهة — فبتنفّذ قبل أي طلب شبكة.
    if (params.password != params.confirmPassword) {
      return const Err<void>(
        ValidationFailure('كلمتا المرور غير متطابقتين'),
      );
    }

    return _authRepository.resetPassword(
      email: params.email,
      code: params.code,
      password: params.password,
    );
  }
}
