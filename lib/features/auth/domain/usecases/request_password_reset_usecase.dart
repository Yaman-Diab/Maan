// -------------------------
// Request Password Reset Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

final class RequestPasswordResetParams extends Equatable {
  final String email;

  const RequestPasswordResetParams({required this.email});

  @override
  List<Object?> get props => [email];
}

class RequestPasswordResetUseCase
    implements UseCase<void, RequestPasswordResetParams> {
  final AuthRepository _authRepository;

  const RequestPasswordResetUseCase(this._authRepository);

  @override
  Future<Result<void>> call(RequestPasswordResetParams params) {
    return _authRepository.requestPasswordReset(email: params.email);
  }
}
