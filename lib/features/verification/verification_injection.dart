// -------------------------
// Verification Dependencies
// -------------------------

import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'data/datasources/verification_remote_data_source.dart';
import 'data/repositories/verification_repository_impl.dart';
import 'domain/repositories/verification_repository.dart';
import 'domain/usecases/submit_verification_usecase.dart';
import 'domain/usecases/update_verification_usecase.dart';

/// domain و data بس — الشاشة لسه ما انبنت، فما في Cubit للتسجيل هون
/// بعد. راجع `CLAUDE.md` › فجوات معروفة.
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
}
