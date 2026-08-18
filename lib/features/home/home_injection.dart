// -------------------------
// Home Dependencies
// -------------------------

import 'package:get_it/get_it.dart';

import '../../core/session/app_session_controller.dart';
import '../complaints/domain/usecases/get_my_complaints_usecase.dart';
import '../news/domain/usecases/get_news_usecase.dart';
import '../profile/domain/usecases/get_profile_usecase.dart';
import '../projects/domain/usecases/get_projects_usecase.dart';
import 'presentation/home/cubit/home_cubit.dart';

/// ⚠️ **بلا domain ولا data** — الرئيسية شاشة تجميع بحتة: كل بياناتها
/// بتجي من use cases تبع ميزات موجودة (profile · news · projects ·
/// complaints). أي منطق عمل جديد مكانه الميزة صاحبة الاختصاص لا هون.
///
/// لازم تُسجَّل **بعد** الميزات اللي بتعتمد عليها بـ`main.dart`.
void registerHomeDependencies(GetIt sl) {
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      sl<GetProfileUseCase>(),
      sl<GetNewsUseCase>(),
      sl<GetProjectsUseCase>(),
      sl<GetMyComplaintsUseCase>(),
      sl<AppSessionController>(),
    ),
  );
}
