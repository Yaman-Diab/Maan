import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/di/service_locator.dart';
import 'package:maan/core/network/api_client.dart';
import 'package:maan/core/session/app_session_controller.dart';
import 'package:maan/core/settings/cubit/settings_cubit.dart';
import 'package:maan/core/storage/settings_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maan/features/auth/auth_injection.dart';
import 'package:maan/features/auth/domain/repositories/auth_repository.dart';
import 'package:maan/features/auth/domain/repositories/session_repository.dart';
import 'package:maan/features/auth/domain/usecases/login_usecase.dart';
import 'package:maan/features/auth/presentation/create_new_password/cubit/create_new_password_cubit.dart';
import 'package:maan/features/auth/presentation/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:maan/features/auth/presentation/login/cubit/login_cubit.dart';
import 'package:maan/features/auth/presentation/sign_up/cubit/sign_up_cubit.dart';
import 'package:maan/features/auth/presentation/verify_email/cubit/verify_email_cubit.dart';
import 'package:maan/features/profile/domain/repositories/profile_repository.dart';
import 'package:maan/features/profile/presentation/profile/cubit/profile_cubit.dart';
import 'package:maan/features/profile/profile_injection.dart';

/// بيتأكد إن نقطة التركيب بتركّب فعلاً.
///
/// كل التسجيلات lazy، فحل `LoginCubit` بيجبر بناء السلسلة كاملة:
/// Cubit → UseCase → Repository → DataSource → ApiClient → Dio → Storage.
/// أي تسجيل ناقص بينكشف هون بدل ما ينفجر بوقت التشغيل.
void main() {
  // SharedPreferences بيمرّ عبر قناة منصّة، فبده binding وقيم مزيّفة.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    await sl.reset();
    await setupCoreDependencies();
    registerAuthDependencies(sl);
    registerProfileDependencies(sl);
  });

  tearDown(() => sl.reset());

  test('سلسلة اعتماديات كل شاشات auth بتتحل كاملة', () {
    expect(sl<LoginCubit>(), isA<LoginCubit>());
    expect(sl<SignUpCubit>(), isA<SignUpCubit>());
    expect(sl<ForgotPasswordCubit>(), isA<ForgotPasswordCubit>());
  });

  test('الشاشات اللي بتاخد وسائط من المسار بتتبنى بـ factoryParam', () {
    final verifyEmail = sl<VerifyEmailCubit>(param1: 'a@b.com');
    expect(verifyEmail.state.email, 'a@b.com');

    final createNewPassword = sl<CreateNewPasswordCubit>(
      param1: 'a@b.com',
      param2: '123456',
    );
    expect(createNewPassword.state.email, 'a@b.com');
    expect(createNewPassword.state.code, '123456');
  });

  test('سلسلة اعتماديات شاشة الملف الشخصي بتتحل كاملة', () {
    // ProfileCubit بياخد AppSessionController من الـ core، فحلّه بيثبت
    // إن ميزة جديدة بتوصل لاعتماديات core بلا ما تسجّلها لحالها.
    expect(sl<ProfileCubit>(), isA<ProfileCubit>());
  });

  test('الـ repositories مسجّلة بواجهاتها لا بتنفيذاتها', () {
    expect(sl<AuthRepository>(), isA<AuthRepository>());
    expect(sl<SessionRepository>(), isA<SessionRepository>());
    expect(sl<ProfileRepository>(), isA<ProfileRepository>());
  });

  test('تفضيلات العرض مسجّلة كـ singleton عام', () {
    expect(sl<SettingsStorageService>(), isA<SettingsStorageService>());
    // على عكس cubits الشاشات: نفس النسخة لكل من يقرأها.
    expect(identical(sl<SettingsCubit>(), sl<SettingsCubit>()), isTrue);
  });

  test('اعتماديات الـ core متاحة لوحدها', () {
    expect(sl<ApiClient>(), isA<ApiClient>());
    expect(sl<AppSessionController>(), isA<AppSessionController>());
  });

  test('الـ Cubit بيتسجّل factory: نسخة جديدة لكل شاشة', () {
    expect(identical(sl<LoginCubit>(), sl<LoginCubit>()), isFalse);
  });

  test('الـ use case بيتسجّل singleton', () {
    expect(identical(sl<LoginUseCase>(), sl<LoginUseCase>()), isTrue);
  });
}
