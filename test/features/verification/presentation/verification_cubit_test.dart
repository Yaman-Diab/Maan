import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/media/picked_image.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/core/session/app_session_controller.dart';
import 'package:maan/core/usecase/usecase.dart';
import 'package:maan/features/auth/domain/entities/auth_user.dart';
import 'package:maan/features/profile/domain/entities/citizen_profile.dart';
import 'package:maan/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:maan/features/verification/domain/entities/verification_request.dart';
import 'package:maan/features/verification/domain/entities/verification_request_status.dart';
import 'package:maan/features/verification/domain/usecases/get_verification_status_usecase.dart';
import 'package:maan/features/verification/domain/usecases/submit_verification_usecase.dart';
import 'package:maan/features/verification/domain/usecases/update_verification_usecase.dart';
import 'package:maan/features/verification/presentation/verification/cubit/verification_cubit.dart';
import 'package:maan/features/verification/presentation/verification/cubit/verification_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetStatus extends Mock implements GetVerificationStatusUseCase {}

class _MockGetProfile extends Mock implements GetProfileUseCase {}

class _MockSubmit extends Mock implements SubmitVerificationUseCase {}

class _MockUpdate extends Mock implements UpdateVerificationUseCase {}

class _MockSession extends Mock implements AppSessionController {}

VerificationRequest _request({
  VerificationRequestStatus status = VerificationRequestStatus.pending,
  String nationalId = '12345678901',
  String? reason,
  String? description,
}) {
  return VerificationRequest(
    id: 7,
    userId: 1,
    nationalId: nationalId,
    status: status,
    images: const [],
    createdAt: DateTime(2026, 8, 2),
    updatedAt: DateTime(2026, 8, 2),
    rejectionReason: reason,
    rejectionDescription: description,
  );
}

CitizenProfile _profile() => const CitizenProfile(
  user: AuthUser(
    id: 1,
    firstName: 'Omar',
    lastName: 'Abo Hawa',
    email: 'omar@example.com',
    accountStatus: AccountStatus.visitor,
  ),
);

PickedImage _image(String name) => PickedImage(
  path: '/tmp/$name',
  bytes: Uint8List.fromList([1]),
  fileName: name,
);

void main() {
  late _MockGetStatus getStatus;
  late _MockGetProfile getProfile;
  late _MockSubmit submit;
  late _MockUpdate update;
  late _MockSession session;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const SubmitVerificationParams(nationalId: '', images: []),
    );
    registerFallbackValue(
      const UpdateVerificationParams(requestId: 0, nationalId: ''),
    );
    registerFallbackValue(AccountStatus.visitor);
  });

  setUp(() {
    getStatus = _MockGetStatus();
    getProfile = _MockGetProfile();
    submit = _MockSubmit();
    update = _MockUpdate();
    session = _MockSession();

    when(() => session.accountStatusChanged(any())).thenAnswer((_) async {});

    // البطاقة الشخصية مش محور هالاختبارات؛ فشل قراءتها مقبول عن قصد
    // (الشاشة بتخفي البطاقة وبتكمّل) — الاختبار المخصّص لها تحت.
    when(
      () => getProfile(any()),
    ).thenAnswer((_) async => const Err(NetworkFailure('error_connection')));
  });

  VerificationCubit build() =>
      VerificationCubit(getStatus, getProfile, submit, update, session);

  group('load — العرض بيتحدّد من حالة الطلب', () {
    blocTest<VerificationCubit, VerificationState>(
      'بلا طلب سابق بتعرض النموذج',
      setUp: () =>
          when(() => getStatus(any())).thenAnswer((_) async => const Ok(null)),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        const VerificationState(view: VerificationView.loading),
        const VerificationState(view: VerificationView.form),
      ],
    );

    blocTest<VerificationCubit, VerificationState>(
      'طلب pending بتعرض «قيد المراجعة» وبتعبّي الرقم الوطني',
      setUp: () =>
          when(() => getStatus(any())).thenAnswer((_) async => Ok(_request())),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.view, VerificationView.pending);
        expect(cubit.state.nationalId, '12345678901');
      },
    );

    blocTest<VerificationCubit, VerificationState>(
      'طلب rejected بتعرض عرض الرفض',
      setUp: () => when(() => getStatus(any())).thenAnswer(
        (_) async => Ok(_request(status: VerificationRequestStatus.rejected)),
      ),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) => expect(cubit.state.view, VerificationView.rejected),
    );

    blocTest<VerificationCubit, VerificationState>(
      'طلب approved بتعرض الاعتماد وبتبلّغ الجلسة إن الحساب صار موثّقاً',
      setUp: () => when(() => getStatus(any())).thenAnswer(
        (_) async => Ok(_request(status: VerificationRequestStatus.approved)),
      ),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.view, VerificationView.approved);
        verify(
          () => session.accountStatusChanged(AccountStatus.verified),
        ).called(1);
      },
    );

    blocTest<VerificationCubit, VerificationState>(
      'حالة unknown بتعرض النموذج — ما بتقفل المستخدم برّا',
      setUp: () => when(() => getStatus(any())).thenAnswer(
        (_) async => Ok(_request(status: VerificationRequestStatus.unknown)),
      ),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) => expect(cubit.state.view, VerificationView.form),
    );

    blocTest<VerificationCubit, VerificationState>(
      'فشل التحميل بيعرض شاشة إعادة المحاولة لا النموذج',
      setUp: () => when(
        () => getStatus(any()),
      ).thenAnswer((_) async => const Err(NetworkFailure('error_connection'))),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.view, VerificationView.loadFailure);
        expect(cubit.state.errorMessage, 'error_connection');
      },
    );
  });

  group('بطاقة البيانات الشخصية', () {
    blocTest<VerificationCubit, VerificationState>(
      'بتتحمّل مع حالة الطلب بنفس الاستدعاء',
      setUp: () {
        when(() => getStatus(any())).thenAnswer((_) async => const Ok(null));
        when(() => getProfile(any())).thenAnswer((_) async => Ok(_profile()));
      },
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.view, VerificationView.form);
        expect(cubit.state.user?.firstName, 'Omar');
      },
    );

    blocTest<VerificationCubit, VerificationState>(
      'فشل قراءتها ما بيوقّع الشاشة — بتضل تعرض النموذج بلا بطاقة',
      setUp: () {
        when(() => getStatus(any())).thenAnswer((_) async => const Ok(null));
        when(() => getProfile(any())).thenAnswer(
          (_) async => const Err(NetworkFailure('error_connection')),
        );
      },
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.view, VerificationView.form);
        expect(cubit.state.user, isNull);
      },
    );
  });

  group('canSubmit', () {
    test('بده رقم وطني صالح وصورتين', () {
      const empty = VerificationState(view: VerificationView.form);
      expect(empty.canSubmit, isFalse);

      final onlyId = empty.copyWith(nationalId: '12345678901');
      expect(onlyId.canSubmit, isFalse, reason: 'بلا صور');

      final full = onlyId.copyWith(
        frontImage: _image('a.jpg'),
        selfieImage: _image('b.jpg'),
      );
      expect(full.canSubmit, isTrue);
    });

    test('رقم أقصر من الحد الأدنى بيمنع الإرسال', () {
      final state = VerificationState(
        view: VerificationView.form,
        nationalId: '123',
        frontImage: _image('a.jpg'),
        selfieImage: _image('b.jpg'),
      );

      expect(state.canSubmit, isFalse);
    });
  });

  group('تصحيح طلب قائم', () {
    blocTest<VerificationCubit, VerificationState>(
      'editRequested بترجّع للنموذج بوضع التصحيح بلا ما تفقد الطلب',
      setUp: () =>
          when(() => getStatus(any())).thenAnswer((_) async => Ok(_request())),
      build: build,
      act: (cubit) async {
        await cubit.load();
        cubit.editRequested();
      },
      verify: (cubit) {
        expect(cubit.state.view, VerificationView.form);
        expect(cubit.state.isEditingExisting, isTrue);
        // الصور مش مطلوبة بالتصحيح — العقد المؤكّد id + national_id بس.
        expect(cubit.state.canSubmit, isTrue);
      },
    );

    blocTest<VerificationCubit, VerificationState>(
      'الإرسال بوضع التصحيح بيضرب update لا submit',
      setUp: () {
        when(() => getStatus(any())).thenAnswer((_) async => Ok(_request()));
        when(
          () => update(any()),
        ).thenAnswer((_) async => Ok(_request(nationalId: '99999999999')));
      },
      build: build,
      act: (cubit) async {
        await cubit.load();
        cubit.editRequested();
        cubit.nationalIdChanged('99999999999');
        await cubit.submit();
      },
      verify: (cubit) {
        verify(
          () => update(
            const UpdateVerificationParams(
              requestId: 7,
              nationalId: '99999999999',
            ),
          ),
        ).called(1);
        verifyNever(() => submit(any()));
        expect(cubit.state.view, VerificationView.pending);
      },
    );
  });

  group('إعادة الإرسال بعد رفض', () {
    blocTest<VerificationCubit, VerificationState>(
      'resubmitRequested بتمسح الطلب القديم فيصير طلباً جديداً لا تصحيحاً',
      setUp: () => when(() => getStatus(any())).thenAnswer(
        (_) async => Ok(_request(status: VerificationRequestStatus.rejected)),
      ),
      build: build,
      act: (cubit) async {
        await cubit.load();
        cubit.resubmitRequested();
      },
      verify: (cubit) {
        expect(cubit.state.view, VerificationView.form);
        expect(cubit.state.request, isNull);
        expect(cubit.state.isEditingExisting, isFalse);
        // الرقم بيضل مبدئياً — الرفض غالباً بسبب الصور لا الرقم.
        expect(cubit.state.nationalId, '12345678901');
      },
    );
  });

  group('الصور', () {
    blocTest<VerificationCubit, VerificationState>(
      'الاختيار والحذف بيأثّروا على الخانة الصحيحة بس',
      setUp: () =>
          when(() => getStatus(any())).thenAnswer((_) async => const Ok(null)),
      build: build,
      act: (cubit) async {
        await cubit.load();
        cubit.imagePicked(DocumentSlot.front, _image('front.jpg'));
        cubit.imagePicked(DocumentSlot.selfie, _image('selfie.jpg'));
        cubit.imageRemoved(DocumentSlot.front);
      },
      verify: (cubit) {
        expect(cubit.state.frontImage, isNull);
        expect(cubit.state.selfieImage?.fileName, 'selfie.jpg');
      },
    );
  });

  group('فشل الإرسال', () {
    blocTest<VerificationCubit, VerificationState>(
      'بيضل بالنموذج مع رسالة الخطأ بدل ما يبدّل العرض',
      setUp: () {
        when(() => getStatus(any())).thenAnswer((_) async => const Ok(null));
        when(() => submit(any())).thenAnswer(
          (_) async => const Err(ValidationFailure('error_validation_generic')),
        );
      },
      build: build,
      act: (cubit) async {
        await cubit.load();
        cubit.nationalIdChanged('12345678901');
        cubit.imagePicked(DocumentSlot.front, _image('front.jpg'));
        cubit.imagePicked(DocumentSlot.selfie, _image('selfie.jpg'));
        await cubit.submit();
      },
      verify: (cubit) {
        expect(cubit.state.view, VerificationView.form);
        expect(cubit.state.submission, VerificationSubmission.failure);
        expect(cubit.state.errorMessage, 'error_validation_generic');
      },
    );
  });
}
