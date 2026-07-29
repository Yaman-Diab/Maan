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
import '../../features/auth/auth_repository.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
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

  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl<ApiClient>()));
}
