// -------------------------
// Profile Dependencies
// -------------------------

import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../core/session/app_session_controller.dart';
import 'data/datasources/profile_remote_data_source.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/get_profile_usecase.dart';
import 'domain/usecases/remove_avatar_usecase.dart';
import 'domain/usecases/upload_avatar_usecase.dart';
import 'presentation/profile/cubit/profile_cubit.dart';

void registerProfileDependencies(GetIt sl) {
  // -------------------------
  // Data
  // -------------------------

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );

  // -------------------------
  // Domain
  // -------------------------

  sl.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(sl<ProfileRepository>()),
  );

  sl.registerLazySingleton<UploadAvatarUseCase>(
    () => UploadAvatarUseCase(sl<ProfileRepository>()),
  );

  sl.registerLazySingleton<RemoveAvatarUseCase>(
    () => RemoveAvatarUseCase(sl<ProfileRepository>()),
  );

  // -------------------------
  // Presentation
  // -------------------------

  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      sl<GetProfileUseCase>(),
      sl<UploadAvatarUseCase>(),
      sl<RemoveAvatarUseCase>(),
      sl<AppSessionController>(),
    ),
  );
}
