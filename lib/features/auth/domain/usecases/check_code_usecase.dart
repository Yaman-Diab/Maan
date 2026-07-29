// -------------------------
// Check Code Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

final class CheckCodeParams extends Equatable {
  final String code;

  const CheckCodeParams({required this.code});

  @override
  List<Object?> get props => [code];
}

class CheckCodeUseCase implements UseCase<void, CheckCodeParams> {
  final AuthRepository _authRepository;

  const CheckCodeUseCase(this._authRepository);

  @override
  Future<Result<void>> call(CheckCodeParams params) {
    return _authRepository.checkCode(code: params.code);
  }
}
