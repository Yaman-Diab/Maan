import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/features/auth/domain/entities/auth_session.dart';
import 'package:maan/features/auth/domain/entities/auth_user.dart';
import 'package:maan/features/auth/domain/usecases/login_usecase.dart';
import 'package:maan/features/auth/presentation/login/cubit/login_cubit.dart';
import 'package:maan/features/auth/presentation/login/cubit/login_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}

const _user = AuthUser(
  id: 1,
  firstName: 'Yaman',
  lastName: 'Diab',
  email: 'a@b.com',
  accountStatus: AccountStatus.visitor,
);

const _session = AuthSession(accessToken: 'access', user: _user);

/// حالة نموذج مكتملة الشروط: بريد وكلمة مرور وموافقة على الشروط.
const _readyState = LoginState(
  email: 'a@b.com',
  password: 'secret',
  isTermsAccepted: true,
);

bool _valid() => true;
bool _invalid() => false;

void main() {
  late _MockLoginUseCase loginUseCase;

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
  });

  setUp(() {
    loginUseCase = _MockLoginUseCase();
  });

  group('canSubmit', () {
    test('بتضل false لحد ما كل الشروط تتحقق', () {
      const state = LoginState();

      expect(state.canSubmit, isFalse);
      expect(state.copyWith(email: 'a@b.com').canSubmit, isFalse);
      expect(
        state.copyWith(email: 'a@b.com', password: 'secret').canSubmit,
        isFalse,
      );
      expect(_readyState.canSubmit, isTrue);
    });

    test('بتنطفي أثناء الإرسال', () {
      expect(
        _readyState.copyWith(status: LoginStatus.submitting).canSubmit,
        isFalse,
      );
    });
  });

  group('تحديث الحقول', () {
    blocTest<LoginCubit, LoginState>(
      'emailChanged بتشيل الفراغات',
      build: () => LoginCubit(loginUseCase),
      act: (cubit) => cubit.emailChanged('  a@b.com  '),
      expect: () => const [LoginState(email: 'a@b.com')],
    );

    blocTest<LoginCubit, LoginState>(
      'passwordChanged ما بتشيل الفراغات',
      build: () => LoginCubit(loginUseCase),
      act: (cubit) => cubit.passwordChanged(' secret '),
      expect: () => const [LoginState(password: ' secret ')],
    );
  });

  group('submit', () {
    blocTest<LoginCubit, LoginState>(
      'ما بتعمل شي لو الشروط ناقصة',
      build: () => LoginCubit(loginUseCase),
      act: (cubit) => cubit.submit(isFormValid: _valid),
      expect: () => const <LoginState>[],
      verify: (_) => verifyNever(() => loginUseCase(any())),
    );

    blocTest<LoginCubit, LoginState>(
      'بتوقف عند فشل تحقق النموذج بس بتفعّل التحقق التلقائي',
      build: () => LoginCubit(loginUseCase),
      seed: () => _readyState,
      act: (cubit) => cubit.submit(isFormValid: _invalid),
      expect: () => [_readyState.copyWith(hasTriedSubmit: true)],
      verify: (_) => verifyNever(() => loginUseCase(any())),
    );

    blocTest<LoginCubit, LoginState>(
      'النجاح: submitting ثم success',
      build: () {
        when(
          () => loginUseCase(any()),
        ).thenAnswer((_) async => const Ok(_session));

        return LoginCubit(loginUseCase);
      },
      seed: () => _readyState,
      act: (cubit) => cubit.submit(isFormValid: _valid),
      expect: () => [
        _readyState.copyWith(hasTriedSubmit: true),
        _readyState.copyWith(
          hasTriedSubmit: true,
          status: LoginStatus.submitting,
        ),
        _readyState.copyWith(
          hasTriedSubmit: true,
          status: LoginStatus.success,
          accountStatus: AccountStatus.visitor,
        ),
      ],
      verify: (_) {
        verify(
          () => loginUseCase(
            const LoginParams(email: 'a@b.com', password: 'secret'),
          ),
        ).called(1);
      },
    );

    blocTest<LoginCubit, LoginState>(
      'الفشل: بتوصل رسالة الـ Failure للحالة',
      build: () {
        when(() => loginUseCase(any())).thenAnswer(
          (_) async =>
              const Err<AuthSession>(AuthFailure('بيانات الدخول غير صحيحة')),
        );

        return LoginCubit(loginUseCase);
      },
      seed: () => _readyState,
      act: (cubit) => cubit.submit(isFormValid: _valid),
      expect: () => [
        _readyState.copyWith(hasTriedSubmit: true),
        _readyState.copyWith(
          hasTriedSubmit: true,
          status: LoginStatus.submitting,
        ),
        _readyState.copyWith(
          hasTriedSubmit: true,
          status: LoginStatus.failure,
          errorMessage: 'بيانات الدخول غير صحيحة',
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'محاولة ثانية بتمسح رسالة الخطأ القديمة',
      build: () {
        when(
          () => loginUseCase(any()),
        ).thenAnswer((_) async => const Ok(_session));

        return LoginCubit(loginUseCase);
      },
      seed: () => _readyState.copyWith(
        hasTriedSubmit: true,
        status: LoginStatus.failure,
        errorMessage: 'خطأ سابق',
      ),
      act: (cubit) => cubit.submit(isFormValid: _valid),
      verify: (cubit) {
        expect(cubit.state.errorMessage, isNull);
        expect(cubit.state.status, LoginStatus.success);
      },
    );
  });
}
