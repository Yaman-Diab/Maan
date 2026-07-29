// -------------------------
// Register Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/birth_date.dart';
import '../repositories/auth_repository.dart';

final class RegisterParams extends Equatable {
  final String firstName;
  final String lastName;
  final BirthDate birthDate;
  final String nationalId;
  final String email;
  final String password;
  final String passwordConfirmation;

  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.nationalId,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    birthDate,
    nationalId,
    email,
    password,
    passwordConfirmation,
  ];
}

class RegisterUseCase implements UseCase<void, RegisterParams> {
  final AuthRepository _authRepository;

  const RegisterUseCase(this._authRepository);

  @override
  Future<Result<void>> call(RegisterParams params) async {
    // تطابق الكلمتين قاعدة عمل، فبتنفّذ قبل أي طلب شبكة.
    if (params.password != params.passwordConfirmation) {
      return const Err<void>(ValidationFailure('كلمتا المرور غير متطابقتين'));
    }

    return _authRepository.register(
      firstName: params.firstName,
      lastName: params.lastName,
      birthDate: params.birthDate,
      nationalId: params.nationalId,
      email: params.email,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
  }
}
