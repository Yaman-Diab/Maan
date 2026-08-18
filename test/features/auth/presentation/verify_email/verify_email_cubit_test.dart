import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/usecase/usecase.dart';
import 'package:maan/features/auth/domain/usecases/check_code_usecase.dart';
import 'package:maan/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:maan/features/auth/presentation/verify_email/cubit/verify_email_cubit.dart';
import 'package:maan/features/auth/presentation/verification_code/cubit/verification_code_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockCheckCodeUseCase extends Mock implements CheckCodeUseCase {}

class _MockResendVerificationUseCase extends Mock
    implements ResendVerificationUseCase {}

const _email = 'a@b.com';

void main() {
  late _MockCheckCodeUseCase checkCodeUseCase;
  late _MockResendVerificationUseCase resendVerificationUseCase;

  /// `cooldownSeconds: 0` بتوقف المؤقّت، فالاختبارات ما بتنتظر بالوقت
  /// الحقيقي — إلا اللي عم يفحص العدّ التنازلي نفسه.
  VerifyEmailCubit build({int cooldownSeconds = 0}) {
    return VerifyEmailCubit(
      checkCodeUseCase,
      resendVerificationUseCase,
      email: _email,
      cooldownSeconds: cooldownSeconds,
    );
  }

  setUpAll(() {
    registerFallbackValue(const CheckCodeParams(code: ''));
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    checkCodeUseCase = _MockCheckCodeUseCase();
    resendVerificationUseCase = _MockResendVerificationUseCase();
  });

  group('canSubmit', () {
    test('بتحتاج رمز بالطول الكامل', () {
      const state = VerificationCodeState(email: _email);

      expect(state.canSubmit, isFalse);
      expect(state.copyWith(code: '12345').canSubmit, isFalse);
      expect(state.copyWith(code: '123456').canSubmit, isTrue);
    });
  });

  group('canResend', () {
    test('ممنوعة أثناء العدّ التنازلي', () {
      const state = VerificationCodeState(email: _email, remainingSeconds: 5);

      expect(state.canResend, isFalse);
      expect(state.copyWith(remainingSeconds: 0).canResend, isTrue);
    });
  });

  group('submit', () {
    blocTest<VerifyEmailCubit, VerificationCodeState>(
      'رمز فيه حروف بيتوقف قبل الشبكة',
      build: build,
      seed: () => const VerificationCodeState(email: _email, code: '12345a'),
      act: (cubit) => cubit.submit(),
      verify: (cubit) {
        expect(cubit.state.codeError, 'code_digits_only');
        verifyNever(() => checkCodeUseCase(any()));
      },
    );

    blocTest<VerifyEmailCubit, VerificationCodeState>(
      'النجاح بيبعت الرمز لحاله بلا بريد',
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
        verify(
          () => checkCodeUseCase(const CheckCodeParams(code: '123456')),
        ).called(1);
      },
    );

    blocTest<VerifyEmailCubit, VerificationCodeState>(
      'خطأ OTP بيظهر تحت الخانات لا كـ SnackBar',
      build: () {
        when(() => checkCodeUseCase(any())).thenAnswer(
          (_) async => const Err<void>(OtpFailure('رمز التحقق غير صحيح')),
        );

        return build();
      },
      seed: () => const VerificationCodeState(email: _email, code: '123456'),
      act: (cubit) => cubit.submit(),
      verify: (cubit) {
        expect(cubit.state.codeError, 'رمز التحقق غير صحيح');
        expect(cubit.state.errorMessage, isNull);
      },
    );

    blocTest<VerifyEmailCubit, VerificationCodeState>(
      'خطأ شبكة بيظهر كـ SnackBar لا تحت الخانات',
      build: () {
        when(() => checkCodeUseCase(any())).thenAnswer(
          (_) async => const Err<void>(NetworkFailure('تعذر الاتصال بالخادم')),
        );

        return build();
      },
      seed: () => const VerificationCodeState(email: _email, code: '123456'),
      act: (cubit) => cubit.submit(),
      verify: (cubit) {
        expect(cubit.state.errorMessage, 'تعذر الاتصال بالخادم');
        expect(cubit.state.codeError, isNull);
      },
    );
  });

  group('resendCode', () {
    blocTest<VerifyEmailCubit, VerificationCodeState>(
      'ما بتشتغل أثناء العدّ التنازلي',
      build: () => build(cooldownSeconds: 30),
      act: (cubit) => cubit.resendCode(),
      verify: (_) => verifyNever(() => resendVerificationUseCase(any())),
    );

    blocTest<VerifyEmailCubit, VerificationCodeState>(
      'النجاح بيفرّغ الرمز',
      build: () {
        when(
          () => resendVerificationUseCase(any()),
        ).thenAnswer((_) async => const Ok<void>(null));

        return build();
      },
      seed: () => const VerificationCodeState(email: _email, code: '123456'),
      act: (cubit) => cubit.resendCode(),
      verify: (cubit) {
        expect(cubit.state.code, isEmpty);
        expect(cubit.state.isResending, isFalse);
        // cooldownSeconds صفر بهذا الاختبار، فما في عدّ ليعاد تشغيله.
        expect(cubit.state.remainingSeconds, 0);
      },
    );

    blocTest<VerifyEmailCubit, VerificationCodeState>(
      'الفشل بيرجّع isResending لـ false وبيعرض الرسالة',
      build: () {
        when(() => resendVerificationUseCase(any())).thenAnswer(
          (_) async => const Err<void>(
            RateLimitFailure('تمت محاولات كثيرة، يرجى الانتظار قليلًا'),
          ),
        );

        return build();
      },
      act: (cubit) => cubit.resendCode(),
      verify: (cubit) {
        expect(cubit.state.isResending, isFalse);
        expect(
          cubit.state.errorMessage,
          'تمت محاولات كثيرة، يرجى الانتظار قليلًا',
        );
      },
    );
  });

  group('العدّ التنازلي', () {
    test('بينقص كل ثانية لحد الصفر', () async {
      final cubit = build(cooldownSeconds: 2);

      expect(cubit.state.remainingSeconds, 2);
      expect(cubit.state.canResend, isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 2200));

      expect(cubit.state.remainingSeconds, 0);
      expect(cubit.state.canResend, isTrue);

      await cubit.close();
    });
  });
}
