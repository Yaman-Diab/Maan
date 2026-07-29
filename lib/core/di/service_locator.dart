// -------------------------
// Service Locator
// -------------------------

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../network/dio_factory.dart';
import '../session/app_session_controller.dart';
import '../session/session_manager.dart';
import '../storage/secure_storage_service.dart';

final sl = GetIt.instance;

/// اعتماديات الـ core فقط.
///
/// ما بتستورد شي من `features` — كل ميزة بتسجّل حالها عبر
/// `register<Feature>Dependencies`، ونقطة التركيب بـ`main.dart`
/// بتنادي الاثنين بالترتيب.
Future<void> setupCoreDependencies() async {
  // -------------------------
  // Storage
  // -------------------------

  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

  // -------------------------
  // Session
  // -------------------------

  sl.registerLazySingleton<AppSessionController>(
    () => AppSessionController(storage: sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<SessionManager>(
    () => SessionManager(
      onUnauthorized: sl<AppSessionController>().handleUnauthorized,
    ),
  );

  // -------------------------
  // Network
  // -------------------------

  sl.registerLazySingleton<Dio>(
    () => DioFactory.create(
      storage: sl<SecureStorageService>(),
      sessionManager: sl<SessionManager>(),
    ),
  );

  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>()));
}
