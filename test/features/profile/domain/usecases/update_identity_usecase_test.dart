import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/domain/birth_date.dart';
import 'package:maan/features/profile/domain/repositories/profile_repository.dart';
import 'package:maan/features/profile/domain/usecases/update_identity_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

const _birthDate = BirthDate(day: 1, month: 2, year: 2003);

void main() {
  late _MockProfileRepository repository;
  late UpdateIdentityUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_birthDate);
  });

  setUp(() {
    repository = _MockProfileRepository();
    useCase = UpdateIdentityUseCase(repository);
  });

  test('بتمرّر الحقول للـ repository بنفس القيم', () async {
    when(
      () => repository.updateIdentity(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        nationalId: any(named: 'nationalId'),
        birthDate: any(named: 'birthDate'),
      ),
    ).thenAnswer((_) async => const Ok<void>(null));

    final result = await useCase(
      const UpdateIdentityParams(
        firstName: 'Yaman',
        lastName: 'Diab',
        nationalId: '123456789012',
        birthDate: _birthDate,
      ),
    );

    expect(result.isOk, isTrue);

    verify(
      () => repository.updateIdentity(
        firstName: 'Yaman',
        lastName: 'Diab',
        nationalId: '123456789012',
        birthDate: _birthDate,
      ),
    ).called(1);
  });

  test('بترجّع نفس نتيجة الفشل من الـ repository', () async {
    when(
      () => repository.updateIdentity(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        nationalId: any(named: 'nationalId'),
        birthDate: any(named: 'birthDate'),
      ),
    ).thenAnswer(
      (_) async => const Err<void>(
        ValidationFailure(
          'error_validation_generic',
          fieldErrors: {
            'national_id': ['The national id has already been taken.'],
          },
        ),
      ),
    );

    final result = await useCase(
      const UpdateIdentityParams(
        firstName: 'Yaman',
        lastName: 'Diab',
        nationalId: '123456789012',
        birthDate: _birthDate,
      ),
    );

    expect(result, isA<Err<void>>());
  });
}
