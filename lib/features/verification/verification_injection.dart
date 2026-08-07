// -------------------------
// Verification Dependencies
// -------------------------

import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../core/session/app_session_controller.dart';
import '../profile/domain/usecases/get_profile_usecase.dart';
import 'data/datasources/verification_remote_data_source.dart';
import 'data/repositories/verification_repository_impl.dart';
import 'domain/repositories/verification_repository.dart';
import 'domain/usecases/get_verification_status_usecase.dart';
import 'domain/usecases/submit_verification_usecase.dart';
import 'domain/usecases/update_verification_usecase.dart';
import 'presentation/verification/cubit/verification_cubit.dart';

void registerVerificationDependencies(GetIt sl) {
  // -------------------------
  // Data
  // -------------------------

  sl.registerLazySingleton<VerificationRemoteDataSource>(
    () => VerificationRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<VerificationRepository>(
    () => VerificationRepositoryImpl(sl<VerificationRemoteDataSource>()),
  );

  // -------------------------
  // Domain
  // -------------------------

  sl.registerLazySingleton<SubmitVerificationUseCase>(
    () => SubmitVerificationUseCase(sl<VerificationRepository>()),
  );

  sl.registerLazySingleton<UpdateVerificationUseCase>(
    () => UpdateVerificationUseCase(sl<VerificationRepository>()),
  );

  sl.registerLazySingleton<GetVerificationStatusUseCase>(
    () => GetVerificationStatusUseCase(sl<VerificationRepository>()),
  );

  // -------------------------
  // Presentation
  // -------------------------

  // factory: كل دخول للشاشة بده Cubit بحالة نظيفة — راجع `CLAUDE.md`.
  // `GetProfileUseCase` من ميزة profile: بطاقة «البيانات الشخصية»
  // بتعرض نفس بيانات المستخدم. استيراد بين ميزتين مقبول هون لأنه use
  // case نقي — نفس سابقة `profile` لما استعملت `AuthUser` من `auth`.
  sl.registerFactory<VerificationCubit>(
    () => VerificationCubit(
      sl<GetVerificationStatusUseCase>(),
      sl<GetProfileUseCase>(),
      sl<SubmitVerificationUseCase>(),
      sl<UpdateVerificationUseCase>(),
      sl<AppSessionController>(),
    ),
  );
}
