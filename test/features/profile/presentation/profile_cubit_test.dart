import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/media/picked_image.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/core/session/app_session_controller.dart';
import 'package:maan/core/storage/secure_storage_service.dart';
import 'package:maan/core/usecase/usecase.dart';
import 'package:maan/features/auth/domain/entities/auth_user.dart';
import 'package:maan/features/profile/domain/entities/citizen_profile.dart';
import 'package:maan/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:maan/features/profile/domain/usecases/remove_avatar_usecase.dart';
import 'package:maan/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:maan/features/profile/presentation/profile/cubit/profile_cubit.dart';
import 'package:maan/features/profile/presentation/profile/cubit/profile_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class _MockUploadAvatarUseCase extends Mock implements UploadAvatarUseCase {}

class _MockRemoveAvatarUseCase extends Mock implements RemoveAvatarUseCase {}

class _MockSecureStorageService extends Mock implements SecureStorageService {}

/// صورة وهمية «بعد» خط الأنابيب — الاختيار والقص والضغط برّا الـ Cubit.
final _pickedImage = PickedImage(
  path: '/tmp/maan_avatar_1.jpg',
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'maan_avatar_1.jpg',
);

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
  late _MockUploadAvatarUseCase uploadAvatar;
  late _MockRemoveAvatarUseCase removeAvatar;
  late _MockSecureStorageService storage;
  late AppSessionController session;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      UploadAvatarParams(bytes: Uint8List(0), fileName: 'x.jpg'),
    );
  });

  setUp(() {
    getProfile = _MockGetProfileUseCase();
    uploadAvatar = _MockUploadAvatarUseCase();
    removeAvatar = _MockRemoveAvatarUseCase();
    storage = _MockSecureStorageService();
    session = AppSessionController(storage: storage);

    when(() => storage.saveAccountStatus(any())).thenAnswer((_) async {});
  });

  ProfileCubit buildCubit() =>
      ProfileCubit(getProfile, uploadAvatar, removeAvatar, session);

  blocTest<ProfileCubit, ProfileState>(
    'النجاح: loading ثم success مع البيانات',
    build: () {
      when(() => getProfile(any())).thenAnswer((_) async => const Ok(_profile));

      return buildCubit();
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
      when(
        () => getProfile(any()),
      ).thenAnswer((_) async => const Err(NetworkFailure('error_connection')));

      return buildCubit();
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

      return buildCubit();
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

  group('رفع الصورة الشخصية', () {
    blocTest<ProfileCubit, ProfileState>(
      'الصورة بتبيّن فوراً قبل ما يرد السيرفر',
      build: () {
        when(
          () => uploadAvatar(any()),
        ).thenAnswer((_) async => const Ok('https://cdn.test/a.jpg'));

        return buildCubit();
      },
      act: (cubit) => cubit.uploadAvatar(_pickedImage),
      expect: () => [
        // أول حالة: المسار موجود والرفع شغّال — هون بتظهر الصورة.
        ProfileState(
          localAvatarPath: _pickedImage.path,
          isUploadingAvatar: true,
        ),
        ProfileState(localAvatarPath: _pickedImage.path),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'فشل الرفع بيرجّع الصورة القديمة ولا بيخلّي وحدة ما انحفظت',
      build: () {
        when(() => uploadAvatar(any())).thenAnswer(
          (_) async => const Err(NetworkFailure('error_connection')),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.uploadAvatar(_pickedImage),
      expect: () => [
        ProfileState(
          localAvatarPath: _pickedImage.path,
          isUploadingAvatar: true,
        ),
        // بلا `localAvatarPath`: عرض صورة السيرفر ما استلمها كذبة.
        const ProfileState(avatarErrorMessage: 'error_connection'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'خطأ الرفع ما بيلمس بيانات الشاشة',
      build: () {
        when(
          () => getProfile(any()),
        ).thenAnswer((_) async => const Ok(_profile));
        when(
          () => uploadAvatar(any()),
        ).thenAnswer((_) async => const Err(ServerFailure('error_server')));

        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load();
        await cubit.uploadAvatar(_pickedImage);
      },
      verify: (cubit) {
        // الملف الشخصي بيضل معروضاً — فشل الصورة سناك بار لا شاشة خطأ.
        expect(cubit.state.profile, _profile);
        expect(cubit.state.status, ProfileStatus.success);
        expect(cubit.state.avatarErrorMessage, 'error_server');
      },
    );

    test('البايتات واسم الملف بينمرّروا كما هم', () async {
      when(() => uploadAvatar(any())).thenAnswer((_) async => const Ok(null));

      await buildCubit().uploadAvatar(_pickedImage);

      final captured =
          verify(() => uploadAvatar(captureAny())).captured.single
              as UploadAvatarParams;

      expect(captured.bytes, _pickedImage.bytes);
      expect(captured.fileName, 'maan_avatar_1.jpg');
    });

    test('رابط فاضي من السيرفر مش فشل — الصورة بتضل ظاهرة', () async {
      // العقد غير مثبّت، فممكن السيرفر ما يرجّع رابطاً أبداً.
      when(() => uploadAvatar(any())).thenAnswer((_) async => const Ok(null));

      final cubit = buildCubit();
      await cubit.uploadAvatar(_pickedImage);

      expect(cubit.state.localAvatarPath, _pickedImage.path);
      expect(cubit.state.avatarErrorMessage, isNull);
      expect(cubit.state.isUploadingAvatar, isFalse);
    });
  });

  group('إزالة الصورة الشخصية', () {
    blocTest<ProfileCubit, ProfileState>(
      'الإزالة تفاؤلية: الأحرف بتبيّن فوراً قبل رد السيرفر',
      build: () {
        when(() => removeAvatar(any())).thenAnswer((_) async => const Ok(null));

        return buildCubit();
      },
      act: (cubit) => cubit.removeAvatar(),
      expect: () => [
        const ProfileState(avatarRemoved: true, isRemovingAvatar: true),
        const ProfileState(avatarRemoved: true),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'فشل الإزالة بيرجّع الصورة القديمة',
      build: () {
        when(
          () => removeAvatar(any()),
        ).thenAnswer((_) async => const Err(ServerFailure('error_server')));

        return buildCubit();
      },
      act: (cubit) => cubit.removeAvatar(),
      expect: () => [
        const ProfileState(avatarRemoved: true, isRemovingAvatar: true),
        // `avatarRemoved` رجعت `false`: عرض الأحرف بدل صورة ما انمسحت
        // فعلياً بالسيرفر كذبة.
        const ProfileState(avatarErrorMessage: 'error_server'),
      ],
    );

    test('بتمسح أي صورة محلية موجودة من رفع سابق هالجلسة', () async {
      when(() => uploadAvatar(any())).thenAnswer((_) async => const Ok(null));
      when(() => removeAvatar(any())).thenAnswer((_) async => const Ok(null));

      final cubit = buildCubit();
      await cubit.uploadAvatar(_pickedImage);
      expect(cubit.state.localAvatarPath, _pickedImage.path);

      await cubit.removeAvatar();

      expect(cubit.state.localAvatarPath, isNull);
      expect(cubit.state.avatarRemoved, isTrue);
    });

    test(
      'إعادة تحميل ناجحة بتلغي علم الإزالة — بيانات السيرفر هي المرجع',
      () async {
        when(
          () => getProfile(any()),
        ).thenAnswer((_) async => const Ok(_profile));
        when(() => removeAvatar(any())).thenAnswer((_) async => const Ok(null));

        final cubit = buildCubit();
        await cubit.removeAvatar();
        expect(cubit.state.avatarRemoved, isTrue);

        await cubit.load();

        expect(cubit.state.avatarRemoved, isFalse);
      },
    );
  });

  group('مزامنة حالة الحساب مع الجلسة', () {
    test('النجاح بيحدّث AppSessionController', () async {
      when(() => getProfile(any())).thenAnswer((_) async => const Ok(_profile));

      expect(session.accountStatus, AccountStatus.unknown);

      await buildCubit().load();

      // `/api/profile` أحدث مصدر لحالة الحساب — التوثيق ممكن يكون
      // اعتُمد بعد آخر تسجيل دخول.
      expect(session.accountStatus, AccountStatus.verified);
      verify(() => storage.saveAccountStatus('verified')).called(1);
    });

    test('الفشل ما بيلمس حالة الحساب', () async {
      when(
        () => getProfile(any()),
      ).thenAnswer((_) async => const Err(ServerFailure('error_server')));

      await buildCubit().load();

      expect(session.accountStatus, AccountStatus.unknown);
      verifyNever(() => storage.saveAccountStatus(any()));
    });
  });
}
