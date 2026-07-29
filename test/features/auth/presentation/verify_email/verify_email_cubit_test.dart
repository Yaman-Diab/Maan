import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:maan/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:maan/features/auth/presentation/verify_email/cubit/verify_email_cubit.dart';
import 'package:maan/features/auth/presentation/verify_email/cubit/verify_email_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}

class _MockResendOtpUseCase extends Mock implements ResendOtpUseCase {}

const _email = 'a@b.com';

void main() {
  late _MockVerifyOtpUseCase verifyOtpUseCase;
  late _MockResendOtpUseCase resendOtpUseCase;

  /// `cooldownSeconds: 0` بتوقف المؤقّت، فالاختبارات ما بتنتظر بالوقت
  /// الحقيقي — إلا اللي عم يفحص العدّ التنازلي نفسه.
  VerifyEmailCubit build({int cooldownSeconds = 0}) {
    return VerifyEmailCubit(
      verifyOtpUseCase,
      resendOtpUseCase,
      email: _email,
      cooldownSeconds: cooldownSeconds,
    );
  }

  setUpAll(() {
    registerFallbackValue(const VerifyOtpParams(email: '', code: ''));
    registerFallbackValue(const ResendOtpParams(email: ''));
  });

  setUp(() {
    verifyOtpUseCase = _MockVerifyOtpUseCase();
    resendOtpUseCase = _MockResendOtpUseCase();
  });

  group('canSubmit', () {
    test('بتحتاج رمز بالطول الكامل', () {
      const state = VerifyEmailState(email: _email);

      expect(state.canSubmit, isFalse);
      expect(state.copyWith(code: '12345').canSubmit, isFalse);
      expect(state.copyWith(code: '123456').canSubmit, isTrue);
    });
  });

  group('canResend', () {
    test('ممنوعة أثناء العدّ التنازلي', () {
      const state = VerifyEmailState(email: _email, remainingSeconds: 5);

      expect(state.canResend, isFalse);
      expect(state.copyWith(remainingSeconds: 0).canResend, isTrue);
    });
  });

  group('submit', () {
    blocTest<VerifyEmailCubit, VerifyEmailState>(
      'رمز فيه حروف بيتوقف قبل الشبكة',
      build: build,
      seed: () => const VerifyEmailState(email: _email, code: '12345a'),
      act: (cubit) => cubit.submit(),
      verify: (cubit) {
        expect(cubit.state.codeError, 'Verification code must contain digits only');
        verifyNever(() => verifyOtpUseCase(any()));
      },
    );

    blocTest<VerifyEmailCubit, VerifyEmailState>(
      'النجاح بينقل الحالة لـ success',
      build: () {
        when(
          () => verifyOtpUseCase(any()),
        ).thenAnswer((_) async => const Ok<void>(null));

        return build();
      },
      seed: () => const VerifyEmailState(email: _email, code: '123456'),
      act: (cubit) => cubit.submit(),
      verify: (cubit) {
        expect(cubit.state.status, VerifyEmailStatus.success);
        verify(
          () => verifyOtpUseCase(
            const VerifyOtpParams(email: _email, code: '123456'),
          ),
        ).called(1);
      },
    );

    blocTest<VerifyEmailCubit, VerifyEmailState>(
      'خطأ OTP بيظهر تحت الخانات لا كـ SnackBar',
      build: () {
        when(() => verifyOtpUseCase(any())).thenAnswer(
          (_) async => const Err<void>(OtpFailure('رمز التحقق غير صحيح')),
        );

        return build();
      },
      seed: () => const VerifyEmailState(email: _email, code: '123456'),
      act: (cubit) => cubit.submit(),
      verify: (cubit) {
        expect(cubit.state.codeError, 'رمز التحقق غير صحيح');
        expect(cubit.state.errorMessage, isNull);
      },
    );

    blocTest<VerifyEmailCubit, VerifyEmailState>(
      'خطأ شبكة بيظهر كـ SnackBar لا تحت الخانات',
      build: () {
        when(() => verifyOtpUseCase(any())).thenAnswer(
          (_) async => const Err<void>(NetworkFailure('تعذر الاتصال بالخادم')),
        );

        return build();
      },
      seed: () => const VerifyEmailState(email: _email, code: '123456'),
      act: (cubit) => cubit.submit(),
      verify: (cubit) {
        expect(cubit.state.errorMessage, 'تعذر الاتصال بالخادم');
        expect(cubit.state.codeError, isNull);
      },
    );
  });

  group('resendCode', () {
    blocTest<VerifyEmailCubit, VerifyEmailState>(
      'ما بتشتغل أثناء العدّ التنازلي',
      build: () => build(cooldownSeconds: 30),
      act: (cubit) => cubit.resendCode(),
      verify: (_) => verifyNever(() => resendOtpUseCase(any())),
    );

    blocTest<VerifyEmailCubit, VerifyEmailState>(
      'النجاح بيفرّغ الرمز وبيعيد تشغيل العدّ',
      build: () {
        when(
          () => resendOtpUseCase(any()),
        ).thenAnswer((_) async => const Ok<void>(null));

        return build();
      },
      seed: () => const VerifyEmailState(email: _email, code: '123456'),
      act: (cubit) => cubit.resendCode(),
      verify: (cubit) {
        expect(cubit.state.code, isEmpty);
        expect(cubit.state.isResending, isFalse);
        // cooldownSeconds صفر بهذا الاختبار، فما في عدّ ليعاد تشغيله.
        expect(cubit.state.remainingSeconds, 0);
      },
    );

    blocTest<VerifyEmailCubit, VerifyEmailState>(
      'الفشل بيرجّع isResending لـ false وبيعرض الرسالة',
      build: () {
        when(() => resendOtpUseCase(any())).thenAnswer(
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
