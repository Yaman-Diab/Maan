// -------------------------
// Resend Verification Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ResendVerificationUseCase implements UseCase<void, NoParams> {
  final AuthRepository _authRepository;

  const ResendVerificationUseCase(this._authRepository);

  @override
  Future<Result<void>> call(NoParams params) {
    return _authRepository.resendVerification();
  }
}
