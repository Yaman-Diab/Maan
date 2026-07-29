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
        email: 'a@b.com',
        code: '123456',
        password: 'Secret1!',
        confirmPassword: 'Different1!',
      ),
    );

    expect(result.failureOrNull, isA<ValidationFailure>());
    expect(result.failureOrNull?.message, 'كلمتا المرور غير متطابقتين');

    verifyNever(
      () => authRepository.resetPassword(
        email: any(named: 'email'),
        code: any(named: 'code'),
        password: any(named: 'password'),
      ),
    );
  });

  test('التطابق بيمرّر الطلب للـ repository', () async {
    when(
      () => authRepository.resetPassword(
        email: any(named: 'email'),
        code: any(named: 'code'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Ok<void>(null));

    final result = await useCase(
      const ResetPasswordParams(
        email: 'a@b.com',
        code: '123456',
        password: 'Secret1!',
        confirmPassword: 'Secret1!',
      ),
    );

    expect(result.isOk, isTrue);

    verify(
      () => authRepository.resetPassword(
        email: 'a@b.com',
        code: '123456',
        password: 'Secret1!',
      ),
    ).called(1);
  });
}
