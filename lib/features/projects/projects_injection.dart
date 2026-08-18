// -------------------------
// Projects Dependencies
// -------------------------

import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../core/session/app_session_controller.dart';
import 'data/datasources/projects_remote_data_source.dart';
import 'data/datasources/projects_remote_data_source_impl.dart';
import 'data/repositories/projects_repository_impl.dart';
import 'domain/repositories/projects_repository.dart';
import 'domain/usecases/get_projects_usecase.dart';
import 'domain/usecases/unvote_project_usecase.dart';
import 'domain/usecases/vote_project_usecase.dart';
import 'domain/usecases/volunteer_for_project_usecase.dart';
import 'presentation/projects/cubit/projects_cubit.dart';

void registerProjectsDependencies(GetIt sl) {
  sl.registerLazySingleton<ProjectsRemoteDataSource>(
    () => ProjectsRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<ProjectsRepository>(
    () => ProjectsRepositoryImpl(sl<ProjectsRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetProjectsUseCase>(
    () => GetProjectsUseCase(sl<ProjectsRepository>()),
  );

  sl.registerLazySingleton<VolunteerForProjectUseCase>(
    () => VolunteerForProjectUseCase(sl<ProjectsRepository>()),
  );

  sl.registerLazySingleton<VoteProjectUseCase>(
    () => VoteProjectUseCase(sl<ProjectsRepository>()),
  );

  sl.registerLazySingleton<UnvoteProjectUseCase>(
    () => UnvoteProjectUseCase(sl<ProjectsRepository>()),
  );

  sl.registerFactory<ProjectsCubit>(
    () => ProjectsCubit(
      sl<GetProjectsUseCase>(),
      sl<VoteProjectUseCase>(),
      sl<UnvoteProjectUseCase>(),
      sl<AppSessionController>(),
    ),
  );
}
