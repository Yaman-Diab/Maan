// -------------------------
// News Dependencies
// -------------------------

import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import 'data/datasources/news_remote_data_source.dart';
import 'data/datasources/news_remote_data_source_impl.dart';
import 'data/repositories/news_repository_impl.dart';
import 'domain/repositories/news_repository.dart';
import 'domain/usecases/get_news_usecase.dart';
import 'presentation/news/cubit/news_cubit.dart';

void registerNewsDependencies(GetIt sl) {
  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(sl<NewsRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetNewsUseCase>(
    () => GetNewsUseCase(sl<NewsRepository>()),
  );

  sl.registerFactory<NewsCubit>(() => NewsCubit(sl<GetNewsUseCase>()));
}
