import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/features/auth/domain/usecases/check_code_usecase.dart';
import 'package:maan/features/auth/domain/usecases/forget_password_usecase.dart';
import 'package:maan/features/auth/presentation/verification_code/cubit/verification_code_state.dart';
import 'package:maan/features/auth/presentation/verify_reset_code/cubit/verify_reset_code_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockCheckCodeUseCase extends Mock implements CheckCodeUseCase {}

class _MockForgetPasswordUseCase extends Mock
    implements ForgetPasswordUseCase {}

const _email = 'a@b.com';

void main() {
  late _MockCheckCodeUseCase checkCodeUseCase;
  late _MockForgetPasswordUseCase forgetPasswordUseCase;

  VerifyResetCodeCubit build({int cooldownSeconds = 0}) {
    return VerifyResetCodeCubit(
      checkCodeUseCase,
      forgetPasswordUseCase,
      email: _email,
      cooldownSeconds: cooldownSeconds,
    );
  }

  setUpAll(() {
    registerFallbackValue(const CheckCodeParams(code: ''));
    registerFallbackValue(const ForgetPasswordParams(email: ''));
  });

  setUp(() {
    checkCodeUseCase = _MockCheckCodeUseCase();
    forgetPasswordUseCase = _MockForgetPasswordUseCase();
  });

  group('submit', () {
    blocTest<VerifyResetCodeCubit, VerificationCodeState>(
      'الرمز الصحيح بيوصل لحالة النجاح وبيضل محفوظاً بالحالة',
      build: () {
        when(
          () => checkCodeUseCase(any()),
        ).thenAnswer((_) async => const Ok<void>(null));

        return build();
      },
      seed: () => const VerificationCodeState(email: _email, code: '123456'),
      act: (cubit) => cubit.submit(),
      verify: (cubit) {
        expect(cubit.state.status, VerificationCodeStatus.success);
        // الشاشة الجاية بتقرأ الرمز من الحالة عشان تبعته مع كلمة المرور
        // الجديدة، فضياعه هون بيرجّع نفس الباگ الأصلي (code فاضي).
        expect(cubit.state.code, '123456');
      },
    );

    blocTest<VerifyResetCodeCubit, VerificationCodeState>(
      'رمز خاطئ بيظهر تحت الخانات لا كـ SnackBar',
      build: () {
        when(() => checkCodeUseCase(any())).thenAnswer(
          (_) async => const Err<void>(OtpFailure('error_otp_invalid')),
        );

        return build();
      },
      seed: () => const VerificationCodeState(email: _email, code: '123456'),
      act: (cubit) => cubit.submit(),
      verify: (cubit) {
        expect(cubit.state.codeError, 'error_otp_invalid');
        expect(cubit.state.errorMessage, isNull);
      },
    );

    blocTest<VerifyResetCodeCubit, VerificationCodeState>(
      'رمز ناقص بيتوقف قبل ما يضرب الشبكة',
      build: build,
      seed: () => const VerificationCodeState(email: _email, code: '123'),
      act: (cubit) => cubit.submit(),
      verify: (_) => verifyNever(() => checkCodeUseCase(any())),
    );
  });

  group('resendCode', () {
    test('بتضرب forgetPassword بنفس البريد لا endpoint تأكيد البريد', () async {
      when(
        () => forgetPasswordUseCase(any()),
      ).thenAnswer((_) async => const Ok<void>(null));

      await build().resendCode();

      final captured =
          verify(() => forgetPasswordUseCase(captureAny())).captured.single
              as ForgetPasswordParams;

      // ما في endpoint مخصّص لإعادة إرسال رمز الاستعادة — إعادة طلب
      // الاستعادة نفسها هي اللي بتولّد رمزاً جديد.
      expect(captured.email, _email);
    });

    blocTest<VerifyResetCodeCubit, VerificationCodeState>(
      'إعادة إرسال ناجحة بتفرّغ الرمز وبتعيد العدّاد',
      build: () {
        when(
          () => forgetPasswordUseCase(any()),
        ).thenAnswer((_) async => const Ok<void>(null));

        return build(cooldownSeconds: 59);
      },
      seed: () => const VerificationCodeState(
        email: _email,
        code: '123456',
        remainingSeconds: 0,
      ),
      act: (cubit) => cubit.resendCode(),
      verify: (cubit) {
        expect(cubit.state.code, isEmpty);
        expect(cubit.state.remainingSeconds, 59);
      },
    );

    blocTest<VerifyResetCodeCubit, VerificationCodeState>(
      'فشل إعادة الإرسال بينعرض كرسالة عامة',
      build: () {
        when(() => forgetPasswordUseCase(any())).thenAnswer(
          (_) async => const Err<void>(NetworkFailure('error_connection')),
        );

        return build();
      },
      act: (cubit) => cubit.resendCode(),
      verify: (cubit) {
        expect(cubit.state.errorMessage, 'error_connection');
        expect(cubit.state.isResending, isFalse);
      },
    );
  });
}
