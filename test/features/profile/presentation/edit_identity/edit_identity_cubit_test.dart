import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/features/auth/domain/entities/auth_user.dart';
import 'package:maan/core/domain/birth_date.dart';
import 'package:maan/features/profile/domain/usecases/update_identity_usecase.dart';
import 'package:maan/features/profile/presentation/edit_identity/cubit/edit_identity_cubit.dart';
import 'package:maan/features/profile/presentation/edit_identity/cubit/edit_identity_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockUpdateIdentityUseCase extends Mock
    implements UpdateIdentityUseCase {}

AuthUser _user({
  AccountStatus status = AccountStatus.visitor,
  String? nationalId = '123456789012',
}) {
  return AuthUser(
    id: 1,
    firstName: 'Yaman',
    lastName: 'Diab',
    email: 'a@b.com',
    accountStatus: status,
    nationalId: nationalId,
    birthDate: DateTime(2003, 2, 1),
  );
}

bool _valid() => true;

void main() {
  late _MockUpdateIdentityUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const UpdateIdentityParams(
        firstName: '',
        lastName: '',
        nationalId: '',
        birthDate: BirthDate(day: 1, month: 1, year: 2000),
      ),
    );
  });

  setUp(() {
    useCase = _MockUpdateIdentityUseCase();
  });

  group('التعبئة الأولية', () {
    test('بتتعبّى من بيانات المستخدم الحالية', () {
      final cubit = EditIdentityCubit(useCase, user: _user());

      expect(cubit.state.firstName, 'Yaman');
      expect(cubit.state.lastName, 'Diab');
      expect(cubit.state.nationalId, '123456789012');
      expect(cubit.state.day, 1);
      expect(cubit.state.month, 2);
      expect(cubit.state.year, 2003);
      expect(cubit.state.isLocked, isFalse);
    });

    test('حساب موثّق بيبني حالة مقفولة', () {
      final cubit = EditIdentityCubit(
        useCase,
        user: _user(status: AccountStatus.verified),
      );

      expect(cubit.state.isLocked, isTrue);
    });

    test('رقم وطني فاضي بيتعبّى نص فاضي لا null', () {
      final cubit = EditIdentityCubit(useCase, user: _user(nationalId: null));

      expect(cubit.state.nationalId, '');
    });
  });

  group('submit — حساب مقفول', () {
    blocTest<EditIdentityCubit, EditIdentityState>(
      'ما بيضرب الشبكة إطلاقاً حتى لو استُدعي مباشرة',
      build: () => EditIdentityCubit(
        useCase,
        user: _user(status: AccountStatus.verified),
      ),
      act: (cubit) => cubit.submit(isFormValid: _valid),
      verify: (_) => verifyNever(() => useCase(any())),
      expect: () => <EditIdentityState>[],
    );
  });

  group('submit — حساب قابل للتعديل', () {
    blocTest<EditIdentityCubit, EditIdentityState>(
      'تاريخ ميلاد غير صالح بيوقف الإرسال قبل الشبكة',
      build: () => EditIdentityCubit(useCase, user: _user()),
      seed: () => const EditIdentityState(
        firstName: 'Yaman',
        lastName: 'Diab',
        nationalId: '123456789012',
        day: 31,
        month: 4,
        year: 2003,
      ),
      act: (cubit) => cubit.submit(isFormValid: _valid),
      verify: (cubit) {
        expect(cubit.state.birthDateError, BirthDateError.invalidDate);
        expect(cubit.state.status, EditIdentityStatus.initial);
        verifyNever(() => useCase(any()));
      },
    );

    blocTest<EditIdentityCubit, EditIdentityState>(
      'شكل الطلب غير صالح بيوقف الإرسال قبل الشبكة — حتى بتاريخ ميلاد سليم',
      build: () => EditIdentityCubit(useCase, user: _user()),
      act: (cubit) => cubit.submit(isFormValid: () => false),
      verify: (cubit) {
        expect(cubit.state.birthDateError, isNull);
        expect(cubit.state.status, EditIdentityStatus.initial);
        expect(cubit.state.hasTriedSubmit, isTrue);
        verifyNever(() => useCase(any()));
      },
    );

    blocTest<EditIdentityCubit, EditIdentityState>(
      'النجاح بيمرّر الحقول ككيان domain للـ birthDate',
      build: () {
        when(
          () => useCase(any()),
        ).thenAnswer((_) async => const Ok<void>(null));

        return EditIdentityCubit(useCase, user: _user());
      },
      act: (cubit) => cubit.submit(isFormValid: _valid),
      verify: (cubit) {
        expect(cubit.state.status, EditIdentityStatus.success);

        final captured =
            verify(() => useCase(captureAny())).captured.single
                as UpdateIdentityParams;

        expect(captured.firstName, 'Yaman');
        expect(captured.nationalId, '123456789012');
        expect(
          captured.birthDate,
          const BirthDate(day: 1, month: 2, year: 2003),
        );
      },
    );

    blocTest<EditIdentityCubit, EditIdentityState>(
      'الفشل بيوصل رسالة الـ Failure للحالة',
      build: () {
        when(() => useCase(any())).thenAnswer(
          (_) async => const Err<void>(
            ValidationFailure('The national id has already been taken.'),
          ),
        );

        return EditIdentityCubit(useCase, user: _user());
      },
      act: (cubit) => cubit.submit(isFormValid: _valid),
      verify: (cubit) {
        expect(cubit.state.status, EditIdentityStatus.failure);
        expect(
          cubit.state.errorMessage,
          'The national id has already been taken.',
        );
      },
    );
  });

  group('قصّ اليوم عند تغيير الشهر أو السنة', () {
    blocTest<EditIdentityCubit, EditIdentityState>(
      'يوم 31 بينقص لـ30 لما الشهر يصير نيسان',
      build: () => EditIdentityCubit(useCase, user: _user()),
      seed: () => const EditIdentityState(day: 31, month: 1, year: 2003),
      act: (cubit) => cubit.monthChanged(4),
      verify: (cubit) {
        expect(cubit.state.month, 4);
        expect(cubit.state.day, 30);
      },
    );
  });
}
