// -------------------------
// Resend OTP Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

final class ResendOtpParams extends Equatable {
  final String email;

  const ResendOtpParams({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResendOtpUseCase implements UseCase<void, ResendOtpParams> {
  final AuthRepository _authRepository;

  const ResendOtpUseCase(this._authRepository);

  @override
  Future<Result<void>> call(ResendOtpParams params) {
    return _authRepository.resendOtp(email: params.email);
  }
}
