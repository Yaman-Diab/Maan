// -------------------------
// Service Locator
// -------------------------

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../media/image_picker_service.dart';
import '../network/api_client.dart';
import '../network/dio_factory.dart';
import '../permissions/app_permission_service.dart';
import '../session/app_session_controller.dart';
import '../session/session_manager.dart';
import '../settings/cubit/settings_cubit.dart';
import '../storage/secure_storage_service.dart';
import '../storage/settings_storage_service.dart';

final sl = GetIt.instance;

/// اعتماديات الـ core فقط.
///
/// ما بتستورد شي من `features` — كل ميزة بتسجّل حالها عبر
/// `register<Feature>Dependencies`، ونقطة التركيب بـ`main.dart`
/// بتنادي الاثنين بالترتيب.
Future<void> setupCoreDependencies() async {
  // -------------------------
  // Storage
  // -------------------------

  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

  // بينقرأ من القرص، فبينحل مرة وحدة هون بدل ما تصير كل قراءة async.
  sl.registerSingleton<SettingsStorageService>(
    await SettingsStorageService.create(),
  );

  // -------------------------
  // Settings
  // -------------------------

  // singleton لا factory: تفضيلات العرض حالة عامة بتعيش طول التطبيق.
  sl.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(sl<SettingsStorageService>()),
  );

  // -------------------------
  // Session
  // -------------------------

  sl.registerLazySingleton<AppSessionController>(
    () => AppSessionController(storage: sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<SessionManager>(
    () => SessionManager(
      onUnauthorized: sl<AppSessionController>().handleUnauthorized,
    ),
  );

  // -------------------------
  // Network
  // -------------------------

  sl.registerLazySingleton<Dio>(
    () => DioFactory.create(
      storage: sl<SecureStorageService>(),
      sessionManager: sl<SessionManager>(),
    ),
  );

  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>()));

  // -------------------------
  // Media
  // -------------------------

  // بالـ core لا بميزة الملف الشخصي: خط أنابيب الصور عام، ورح تحتاجه
  // مرفقات الشكاوى وصور التوثيق كمان.
  sl.registerLazySingleton<ImagePickerService>(() => ImagePickerService());

  // -------------------------
  // Permissions
  // -------------------------

  sl.registerLazySingleton<AppPermissionService>(
    () => const AppPermissionService(),
  );
}
