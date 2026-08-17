// -------------------------
// Municipal Services Dependencies
// -------------------------

import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'data/datasources/municipal_services_remote_data_source.dart';
import 'data/repositories/municipal_services_repository_impl.dart';
import 'domain/repositories/municipal_services_repository.dart';
import 'domain/usecases/get_municipal_services_usecase.dart';
import 'presentation/municipal_services/cubit/municipal_services_cubit.dart';

void registerMunicipalServicesDependencies(GetIt sl) {
  sl.registerLazySingleton<MunicipalServicesRemoteDataSource>(
    () => MunicipalServicesRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<MunicipalServicesRepository>(
    () => MunicipalServicesRepositoryImpl(
      sl<MunicipalServicesRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetMunicipalServicesUseCase>(
    () => GetMunicipalServicesUseCase(sl<MunicipalServicesRepository>()),
  );

  sl.registerFactory<MunicipalServicesCubit>(
    () => MunicipalServicesCubit(sl<GetMunicipalServicesUseCase>()),
  );
}
