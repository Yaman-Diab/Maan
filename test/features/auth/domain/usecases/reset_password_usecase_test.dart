import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/features/auth/domain/repositories/auth_repository.dart';
import 'package:maan/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository authRepository;
  late ResetPasswordUseCase useCase;

  setUp(() {
    authRepository = _MockAuthRepository();
    useCase = ResetPasswordUseCase(authRepository);
  });

  test('عدم تطابق الكلمتين بيفشل قبل أي طلب شبكة', () async {
    final result = await useCase(
      const ResetPasswordParams(
        code: '900482',
        password: 'Secret1!',
        passwordConfirmation: 'Different1!',
      ),
    );

    expect(result.failureOrNull, isA<ValidationFailure>());
    expect(result.failureOrNull?.message, 'كلمتا المرور غير متطابقتين');

    verifyNever(
      () => authRepository.resetPassword(
        code: any(named: 'code'),
        password: any(named: 'password'),
        passwordConfirmation: any(named: 'passwordConfirmation'),
      ),
    );
  });

  test('التطابق بيمرّر الطلب للـ repository', () async {
    when(
      () => authRepository.resetPassword(
        code: any(named: 'code'),
        password: any(named: 'password'),
        passwordConfirmation: any(named: 'passwordConfirmation'),
      ),
    ).thenAnswer((_) async => const Ok<void>(null));

    final result = await useCase(
      const ResetPasswordParams(
        code: '900482',
        password: 'Secret1!',
        passwordConfirmation: 'Secret1!',
      ),
    );

    expect(result.isOk, isTrue);

    verify(
      () => authRepository.resetPassword(
        code: '900482',
        password: 'Secret1!',
        passwordConfirmation: 'Secret1!',
      ),
    ).called(1);
  });
}
