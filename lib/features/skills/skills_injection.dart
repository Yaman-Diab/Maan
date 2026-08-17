// -------------------------
// Skills Dependencies
// -------------------------

import 'package:get_it/get_it.dart';

import '../../core/media/certificate_file_picker_service.dart';
import '../../core/network/api_client.dart';
import 'data/datasources/skills_remote_data_source.dart';
import 'data/repositories/skills_repository_impl.dart';
import 'domain/repositories/skills_repository.dart';
import 'domain/usecases/add_skill_usecase.dart';
import 'domain/usecases/attach_certificate_usecase.dart';
import 'domain/usecases/delete_skill_usecase.dart';
import 'domain/usecases/get_skills_usecase.dart';
import 'domain/usecases/replace_certificate_usecase.dart';
import 'domain/usecases/update_skill_usecase.dart';
import 'presentation/skills/cubit/skills_cubit.dart';

void registerSkillsDependencies(GetIt sl) {
  // -------------------------
  // Core
  // -------------------------

  sl.registerLazySingleton<CertificateFilePickerService>(
    () => const CertificateFilePickerService(),
  );

  // -------------------------
  // Data
  // -------------------------

  sl.registerLazySingleton<SkillsRemoteDataSource>(
    () => SkillsRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<SkillsRepository>(
    () => SkillsRepositoryImpl(sl<SkillsRemoteDataSource>()),
  );

  // -------------------------
  // Domain
  // -------------------------

  sl.registerLazySingleton<GetSkillsUseCase>(
    () => GetSkillsUseCase(sl<SkillsRepository>()),
  );

  sl.registerLazySingleton<AddSkillUseCase>(
    () => AddSkillUseCase(sl<SkillsRepository>()),
  );

  sl.registerLazySingleton<UpdateSkillUseCase>(
    () => UpdateSkillUseCase(sl<SkillsRepository>()),
  );

  sl.registerLazySingleton<DeleteSkillUseCase>(
    () => DeleteSkillUseCase(sl<SkillsRepository>()),
  );

  sl.registerLazySingleton<AttachCertificateUseCase>(
    () => AttachCertificateUseCase(sl<SkillsRepository>()),
  );

  sl.registerLazySingleton<ReplaceCertificateUseCase>(
    () => ReplaceCertificateUseCase(sl<SkillsRepository>()),
  );

  // -------------------------
  // Presentation
  // -------------------------

  // بس `GetSkillsUseCase` — عمليات الإضافة/التعديل/الحذف/إرفاق الشهادة
  // بتصير مباشرة من الورقة/الشاشة المسؤولة عبر `sl<...>()`، نفس نمط
  // `ComplaintReportSheet`، وبتعيد تحميل القائمة بعد النجاح بدل ما
  // الـCubit يحمل كل الحالات الوسيطة (رفع، حفظ...) لكل عملية.
  sl.registerFactory<SkillsCubit>(() => SkillsCubit(sl<GetSkillsUseCase>()));
}
