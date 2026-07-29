// -------------------------
// Auth Dependencies
// -------------------------

import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/session_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/session_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'presentation/login/cubit/login_cubit.dart';

/// تسجيل اعتماديات ميزة auth.
///
/// الميزة هي اللي بتسجّل حالها، فـ`core` ما بتستورد شي من `features`.
/// نقطة التركيب (`main.dart`) بتنادي هذا بعد اعتماديات الـ core.
void registerAuthDependencies(GetIt sl) {
  // -------------------------
  // Data
  // -------------------------

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sl<SecureStorageService>()),
  );

  // -------------------------
  // Domain
  // -------------------------

  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>(), sl<SessionRepository>()),
  );

  // -------------------------
  // Presentation
  // -------------------------

  // factory مش singleton: كل دخول للشاشة بده Cubit بحالة نظيفة.
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl<LoginUseCase>()));
}
