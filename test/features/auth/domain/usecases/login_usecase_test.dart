import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/features/auth/domain/entities/auth_session.dart';
import 'package:maan/features/auth/domain/entities/auth_user.dart';
import 'package:maan/features/auth/domain/repositories/auth_repository.dart';
import 'package:maan/features/auth/domain/repositories/session_repository.dart';
import 'package:maan/features/auth/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSessionRepository extends Mock implements SessionRepository {}

const _user = AuthUser(
  id: 1,
  firstName: 'Yaman',
  lastName: 'Diab',
  email: 'a@b.com',
  accountStatus: AccountStatus.visitor,
);

const _session = AuthSession(accessToken: 'access', user: _user);

const _params = LoginParams(email: 'a@b.com', password: 'secret');

void main() {
  late _MockAuthRepository authRepository;
  late _MockSessionRepository sessionRepository;
  late LoginUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_session);
  });

  setUp(() {
    authRepository = _MockAuthRepository();
    sessionRepository = _MockSessionRepository();
    useCase = LoginUseCase(authRepository, sessionRepository);
  });

  test('عند النجاح بتنحفظ الجلسة وبترجع نفس النتيجة', () async {
    when(
      () => authRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Ok(_session));

    when(
      () => sessionRepository.persistSession(any()),
    ).thenAnswer((_) async {});

    final result = await useCase(_params);

    expect(result, isA<Ok<AuthSession>>());
    expect(result.valueOrNull, _session);

    verify(
      () => authRepository.login(email: 'a@b.com', password: 'secret'),
    ).called(1);
    verify(() => sessionRepository.persistSession(_session)).called(1);
  });

  test('عند الفشل ما بتنحفظ أي جلسة', () async {
    const failure = AuthFailure('بيانات الدخول غير صحيحة');

    when(
      () => authRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Err<AuthSession>(failure));

    final result = await useCase(_params);

    expect(result, isA<Err<AuthSession>>());
    expect(result.failureOrNull, failure);

    verifyNever(() => sessionRepository.persistSession(any()));
  });
}
