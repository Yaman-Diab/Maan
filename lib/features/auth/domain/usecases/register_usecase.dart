// -------------------------
// Register Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import 'package:maan/core/domain/birth_date.dart';
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

  /// تطابق الكلمتين تحقّق واجهة أصلاً (`AppValidators.confirmPasswordValidator`)
  /// ومترجم بـ`passwords_do_not_match` — الفورم بيمنع الإرسال قبل ما توصل
  /// هون، فتكرار الفحص هون بس بيعني نص عربي إضافي بلا ترجمة إنجليزية.
  @override
  Future<Result<void>> call(RegisterParams params) {
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
