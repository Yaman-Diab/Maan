import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/core/session/app_session_controller.dart';
import 'package:maan/core/storage/secure_storage_service.dart';
import 'package:maan/core/usecase/usecase.dart';
import 'package:maan/features/auth/domain/entities/auth_user.dart';
import 'package:maan/features/profile/domain/entities/citizen_profile.dart';
import 'package:maan/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:maan/features/profile/presentation/profile/cubit/profile_cubit.dart';
import 'package:maan/features/profile/presentation/profile/cubit/profile_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class _MockSecureStorageService extends Mock implements SecureStorageService {}

const _verifiedUser = AuthUser(
  id: 7,
  firstName: 'Yaman',
  lastName: 'Diab',
  email: 'yamandiab7@gmail.com',
  accountStatus: AccountStatus.verified,
);

const _profile = CitizenProfile(user: _verifiedUser);

void main() {
  late _MockGetProfileUseCase getProfile;
  late _MockSecureStorageService storage;
  late AppSessionController session;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getProfile = _MockGetProfileUseCase();
    storage = _MockSecureStorageService();
    session = AppSessionController(storage: storage);

    when(() => storage.saveAccountStatus(any())).thenAnswer((_) async {});
  });

  blocTest<ProfileCubit, ProfileState>(
    'النجاح: loading ثم success مع البيانات',
    build: () {
      when(() => getProfile(any())).thenAnswer((_) async => const Ok(_profile));

      return ProfileCubit(getProfile, session);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const ProfileState(status: ProfileStatus.loading),
      const ProfileState(status: ProfileStatus.success, profile: _profile),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'الفشل: loading ثم failure مع رسالة جاهزة للعرض',
    build: () {
      when(() => getProfile(any())).thenAnswer(
        (_) async => const Err(NetworkFailure('error_connection')),
      );

      return ProfileCubit(getProfile, session);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const ProfileState(status: ProfileStatus.loading),
      const ProfileState(
        status: ProfileStatus.failure,
        errorMessage: 'error_connection',
      ),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'إعادة التحميل بتحافظ على البيانات القديمة تحت مؤشّر التحميل',
    build: () {
      when(() => getProfile(any())).thenAnswer((_) async => const Ok(_profile));

      return ProfileCubit(getProfile, session);
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.load();
    },
    verify: (cubit) {
      // بعد أول تحميل ناجح، أي loading تاني ما بيمسح البيانات — فما
      // بتومض الشاشة فاضية عند السحب للتحديث.
      expect(cubit.state.profile, _profile);
      expect(cubit.state.isFirstLoad, isFalse);
    },
  );

  group('مزامنة حالة الحساب مع الجلسة', () {
    test('النجاح بيحدّث AppSessionController', () async {
      when(() => getProfile(any())).thenAnswer((_) async => const Ok(_profile));

      expect(session.accountStatus, AccountStatus.unknown);

      await ProfileCubit(getProfile, session).load();

      // `/api/profile` أحدث مصدر لحالة الحساب — التوثيق ممكن يكون
      // اعتُمد بعد آخر تسجيل دخول.
      expect(session.accountStatus, AccountStatus.verified);
      verify(() => storage.saveAccountStatus('verified')).called(1);
    });

    test('الفشل ما بيلمس حالة الحساب', () async {
      when(() => getProfile(any())).thenAnswer(
        (_) async => const Err(ServerFailure('error_server')),
      );

      await ProfileCubit(getProfile, session).load();

      expect(session.accountStatus, AccountStatus.unknown);
      verifyNever(() => storage.saveAccountStatus(any()));
    });
  });
}
