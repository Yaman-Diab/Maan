// -------------------------
// Complaints Dependencies
// -------------------------

import 'package:get_it/get_it.dart';

import '../../core/location/location_service.dart';
import '../../core/network/api_client.dart';
import '../../core/session/app_session_controller.dart';
import 'data/datasources/complaints_remote_data_source.dart';
import 'data/repositories/complaints_repository_impl.dart';
import 'domain/repositories/complaints_repository.dart';
import 'domain/usecases/get_my_complaints_usecase.dart';
import 'domain/usecases/get_published_complaints_usecase.dart';
import 'domain/usecases/report_complaint_usecase.dart';
import 'domain/usecases/submit_complaint_usecase.dart';
import 'domain/usecases/unvote_complaint_usecase.dart';
import 'domain/usecases/vote_complaint_usecase.dart';
import 'presentation/complaints/cubit/complaints_cubit.dart';
import 'presentation/submit_complaint/cubit/submit_complaint_cubit.dart';

void registerComplaintsDependencies(GetIt sl) {
  // -------------------------
  // Data
  // -------------------------

  sl.registerLazySingleton<ComplaintsRemoteDataSource>(
    () => ComplaintsRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<ComplaintsRepository>(
    () => ComplaintsRepositoryImpl(sl<ComplaintsRemoteDataSource>()),
  );

  // -------------------------
  // Domain
  // -------------------------

  sl.registerLazySingleton<GetPublishedComplaintsUseCase>(
    () => GetPublishedComplaintsUseCase(sl<ComplaintsRepository>()),
  );

  sl.registerLazySingleton<GetMyComplaintsUseCase>(
    () => GetMyComplaintsUseCase(sl<ComplaintsRepository>()),
  );

  sl.registerLazySingleton<SubmitComplaintUseCase>(
    () => SubmitComplaintUseCase(sl<ComplaintsRepository>()),
  );

  sl.registerLazySingleton<VoteComplaintUseCase>(
    () => VoteComplaintUseCase(sl<ComplaintsRepository>()),
  );

  sl.registerLazySingleton<UnvoteComplaintUseCase>(
    () => UnvoteComplaintUseCase(sl<ComplaintsRepository>()),
  );

  sl.registerLazySingleton<ReportComplaintUseCase>(
    () => ReportComplaintUseCase(sl<ComplaintsRepository>()),
  );

  // -------------------------
  // Presentation
  // -------------------------

  sl.registerFactory<ComplaintsCubit>(
    () => ComplaintsCubit(
      sl<GetPublishedComplaintsUseCase>(),
      sl<GetMyComplaintsUseCase>(),
      sl<VoteComplaintUseCase>(),
      sl<UnvoteComplaintUseCase>(),
      sl<AppSessionController>(),
    ),
  );

  sl.registerFactory<SubmitComplaintCubit>(
    () => SubmitComplaintCubit(
      sl<SubmitComplaintUseCase>(),
      sl<LocationService>(),
    ),
  );
}
