// -------------------------
// Register Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/birth_date.dart';
import '../repositories/auth_repository.dart';

final class RegisterParams extends Equatable {
  final String firstName;
  final String lastName;
  final BirthDate birthDate;
  final String email;
  final String password;

  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [firstName, lastName, birthDate, email, password];
}

class RegisterUseCase implements UseCase<void, RegisterParams> {
  final AuthRepository _authRepository;

  const RegisterUseCase(this._authRepository);

  @override
  Future<Result<void>> call(RegisterParams params) {
    return _authRepository.register(
      firstName: params.firstName,
      lastName: params.lastName,
      birthDate: params.birthDate,
      email: params.email,
      password: params.password,
    );
  }
}
