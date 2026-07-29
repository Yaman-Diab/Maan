// -------------------------
// Verify OTP Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

final class VerifyOtpParams extends Equatable {
  final String email;
  final String code;

  const VerifyOtpParams({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

class VerifyOtpUseCase implements UseCase<void, VerifyOtpParams> {
  final AuthRepository _authRepository;

  const VerifyOtpUseCase(this._authRepository);

  @override
  Future<Result<void>> call(VerifyOtpParams params) {
    return _authRepository.verifyOtp(email: params.email, code: params.code);
  }
}
