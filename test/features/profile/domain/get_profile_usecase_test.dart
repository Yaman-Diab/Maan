import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/core/usecase/usecase.dart';
import 'package:maan/features/auth/domain/entities/auth_user.dart';
import 'package:maan/features/profile/domain/entities/citizen_profile.dart';
import 'package:maan/features/profile/domain/entities/profile_stats.dart';
import 'package:maan/features/profile/domain/repositories/profile_repository.dart';
import 'package:maan/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

const _user = AuthUser(
  id: 7,
  firstName: 'Yaman',
  lastName: 'Diab',
  email: 'yamandiab7@gmail.com',
  accountStatus: AccountStatus.verified,
);

const _profile = CitizenProfile(user: _user);

void main() {
  late _MockProfileRepository repository;
  late GetProfileUseCase useCase;

  setUp(() {
    repository = _MockProfileRepository();
    useCase = GetProfileUseCase(repository);
  });

  test('بتمرّر نتيجة النجاح كما هي', () async {
    when(
      () => repository.getProfile(),
    ).thenAnswer((_) async => const Ok(_profile));

    final result = await useCase(const NoParams());

    expect(result, isA<Ok<CitizenProfile>>());
    expect((result as Ok).value.user, _user);
    verify(() => repository.getProfile()).called(1);
  });

  test('بتمرّر الفشل كما هو بلا تحويل', () async {
    when(() => repository.getProfile()).thenAnswer(
      (_) async => const Err(NetworkFailure('error_connection')),
    );

    final result = await useCase(const NoParams());

    expect((result as Err).failure, isA<NetworkFailure>());
  });

  test('ما بتاخد مدخلات — المستخدم بينحدد من التوكن', () async {
    when(
      () => repository.getProfile(),
    ).thenAnswer((_) async => const Ok(_profile));

    await useCase(const NoParams());

    verify(() => repository.getProfile()).called(1);
    verifyNoMoreInteractions(repository);
  });

  group('عتبات المستوى', () {
    test('75 فما فوق متقدّم', () {
      expect(ProfileStats.levelOf(75), StatLevel.advanced);
      expect(ProfileStats.levelOf(100), StatLevel.advanced);
    });

    test('من 40 لـ74 متوسط', () {
      expect(ProfileStats.levelOf(40), StatLevel.intermediate);
      expect(ProfileStats.levelOf(74), StatLevel.intermediate);
    });

    test('تحت 40 مبتدئ', () {
      expect(ProfileStats.levelOf(39), StatLevel.beginner);
      expect(ProfileStats.levelOf(0), StatLevel.beginner);
    });
  });
}
