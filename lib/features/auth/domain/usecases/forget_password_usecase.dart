// -------------------------
// Forget Password Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

final class ForgetPasswordParams extends Equatable {
  final String email;

  const ForgetPasswordParams({required this.email});

  @override
  List<Object?> get props => [email];
}

class ForgetPasswordUseCase implements UseCase<void, ForgetPasswordParams> {
  final AuthRepository _authRepository;

  const ForgetPasswordUseCase(this._authRepository);

  @override
  Future<Result<void>> call(ForgetPasswordParams params) {
    return _authRepository.forgetPassword(email: params.email);
  }
}
