import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/features/auth/domain/repositories/auth_repository.dart';
import 'package:maan/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// تطابق الكلمتين تحقّق واجهة (`AppValidators.confirmPasswordValidator`)،
/// فالـ use case هون مجرّد تفويض للـ repository — راجع تعليق
/// `ResetPasswordUseCase.call`.
void main() {
  late _MockAuthRepository authRepository;
  late ResetPasswordUseCase useCase;

  setUp(() {
    authRepository = _MockAuthRepository();
    useCase = ResetPasswordUseCase(authRepository);
  });

  test('بتمرّر الطلب للـ repository بنفس الوسائط', () async {
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

  test('بترجّع نفس نتيجة الفشل من الـ repository', () async {
    when(
      () => authRepository.resetPassword(
        code: any(named: 'code'),
        password: any(named: 'password'),
        passwordConfirmation: any(named: 'passwordConfirmation'),
      ),
    ).thenAnswer((_) async => const Err<void>(NetworkFailure('تعذر الاتصال')));

    final result = await useCase(
      const ResetPasswordParams(
        code: '900482',
        password: 'Secret1!',
        passwordConfirmation: 'Secret1!',
      ),
    );

    expect(result, isA<Err<void>>());
  });
}
