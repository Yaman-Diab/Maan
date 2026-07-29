import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/di/service_locator.dart';
import 'package:maan/core/network/api_client.dart';
import 'package:maan/core/session/app_session_controller.dart';
import 'package:maan/features/auth/auth_injection.dart';
import 'package:maan/features/auth/domain/repositories/auth_repository.dart';
import 'package:maan/features/auth/domain/repositories/session_repository.dart';
import 'package:maan/features/auth/domain/usecases/login_usecase.dart';
import 'package:maan/features/auth/presentation/login/cubit/login_cubit.dart';

/// بيتأكد إن نقطة التركيب بتركّب فعلاً.
///
/// كل التسجيلات lazy، فحل `LoginCubit` بيجبر بناء السلسلة كاملة:
/// Cubit → UseCase → Repository → DataSource → ApiClient → Dio → Storage.
/// أي تسجيل ناقص بينكشف هون بدل ما ينفجر بوقت التشغيل.
void main() {
  setUp(() async {
    await sl.reset();
    await setupCoreDependencies();
    registerAuthDependencies(sl);
  });

  tearDown(() => sl.reset());

  test('سلسلة اعتماديات تسجيل الدخول بتتحل كاملة', () {
    expect(sl<LoginCubit>(), isA<LoginCubit>());
  });

  test('الـ repositories مسجّلة بواجهاتها لا بتنفيذاتها', () {
    expect(sl<AuthRepository>(), isA<AuthRepository>());
    expect(sl<SessionRepository>(), isA<SessionRepository>());
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
