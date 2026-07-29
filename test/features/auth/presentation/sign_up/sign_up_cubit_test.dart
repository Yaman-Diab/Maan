import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/features/auth/domain/entities/birth_date.dart';
import 'package:maan/features/auth/domain/usecases/register_usecase.dart';
import 'package:maan/features/auth/presentation/sign_up/cubit/sign_up_cubit.dart';
import 'package:maan/features/auth/presentation/sign_up/cubit/sign_up_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockRegisterUseCase extends Mock implements RegisterUseCase {}

/// حالة مكتملة الشروط بتاريخ ميلاد صالح.
const _readyState = SignUpState(
  firstName: 'Ahmad',
  lastName: 'Abo Hawa',
  nationalId: '09477224563',
  day: 1,
  month: 1,
  year: 2000,
  email: 'a@b.com',
  password: 'Secret1!',
  confirmPassword: 'Secret1!',
  isTermsAccepted: true,
);

bool _valid() => true;

void main() {
  late _MockRegisterUseCase registerUseCase;

  setUpAll(() {
    registerFallbackValue(
      const RegisterParams(
        firstName: '',
        lastName: '',
        birthDate: BirthDate(day: 1, month: 1, year: 2000),
        nationalId: '',
        email: '',
        password: '',
        passwordConfirmation: '',
      ),
    );
  });

  setUp(() {
    registerUseCase = _MockRegisterUseCase();
  });

  group('canSubmit', () {
    test('بتحتاج كل الحقول والموافقة على الشروط', () {
      expect(const SignUpState().canSubmit, isFalse);
      expect(_readyState.canSubmit, isTrue);
      expect(_readyState.copyWith(isTermsAccepted: false).canSubmit, isFalse);
      expect(
        _readyState.copyWith(status: SignUpStatus.submitting).canSubmit,
        isFalse,
      );
    });

    test('تاريخ ميلاد ناقص بيمنع الإرسال', () {
      const missingDay = SignUpState(
        firstName: 'Ahmad',
        lastName: 'Abo Hawa',
        month: 1,
        year: 2000,
        email: 'a@b.com',
        password: 'Secret1!',
        confirmPassword: 'Secret1!',
        isTermsAccepted: true,
      );

      expect(missingDay.canSubmit, isFalse);
    });
  });

  group('قصّ اليوم عند تغيير الشهر أو السنة', () {
    blocTest<SignUpCubit, SignUpState>(
      'يوم 31 بينقص لـ30 لما الشهر يصير نيسان',
      build: () => SignUpCubit(registerUseCase),
      seed: () => const SignUpState(day: 31, month: 1, year: 2000),
      act: (cubit) => cubit.monthChanged(4),
      verify: (cubit) {
        expect(cubit.state.month, 4);
        expect(cubit.state.day, 30);
      },
    );

    blocTest<SignUpCubit, SignUpState>(
      '29 شباط بينقص لـ28 لما السنة تصير غير كبيسة',
      build: () => SignUpCubit(registerUseCase),
      seed: () => const SignUpState(day: 29, month: 2, year: 2000),
      act: (cubit) => cubit.yearChanged(2001),
      verify: (cubit) {
        expect(cubit.state.year, 2001);
        expect(cubit.state.day, 28);
      },
    );

    blocTest<SignUpCubit, SignUpState>(
      'يوم صالح ما بينمس',
      build: () => SignUpCubit(registerUseCase),
      seed: () => const SignUpState(day: 15, month: 1, year: 2000),
      act: (cubit) => cubit.monthChanged(4),
      verify: (cubit) => expect(cubit.state.day, 15),
    );
  });

  group('submit', () {
    blocTest<SignUpCubit, SignUpState>(
      'تاريخ ميلاد غير صالح بيوقف الإرسال قبل الشبكة',
      build: () => SignUpCubit(registerUseCase),
      // 31 نيسان ما بينوجد.
      seed: () => _readyState.copyWith(day: 31, month: 4),
      act: (cubit) => cubit.submit(isFormValid: _valid),
      verify: (cubit) {
        expect(cubit.state.birthDateError, BirthDateError.invalidDate);
        expect(cubit.state.status, SignUpStatus.initial);
        verifyNever(() => registerUseCase(any()));
      },
    );

    blocTest<SignUpCubit, SignUpState>(
      'النجاح بيمرّر تاريخ الميلاد ككيان domain',
      build: () {
        when(
          () => registerUseCase(any()),
        ).thenAnswer((_) async => const Ok<void>(null));

        return SignUpCubit(registerUseCase);
      },
      seed: () => _readyState,
      act: (cubit) => cubit.submit(isFormValid: _valid),
      verify: (cubit) {
        expect(cubit.state.status, SignUpStatus.success);

        final captured =
            verify(() => registerUseCase(captureAny())).captured.single
                as RegisterParams;

        expect(captured.birthDate, const BirthDate(day: 1, month: 1, year: 2000));
        expect(captured.email, 'a@b.com');
        expect(captured.passwordConfirmation, 'Secret1!');
      },
    );

    blocTest<SignUpCubit, SignUpState>(
      'الفشل بيوصل رسالة الـ Failure للحالة',
      build: () {
        when(() => registerUseCase(any())).thenAnswer(
          (_) async =>
              const Err<void>(ValidationFailure('هذا البريد مستخدم مسبقاً')),
        );

        return SignUpCubit(registerUseCase);
      },
      seed: () => _readyState,
      act: (cubit) => cubit.submit(isFormValid: _valid),
      verify: (cubit) {
        expect(cubit.state.status, SignUpStatus.failure);
        expect(cubit.state.errorMessage, 'هذا البريد مستخدم مسبقاً');
      },
    );
  });
}
