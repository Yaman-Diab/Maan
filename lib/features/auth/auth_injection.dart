// -------------------------
// Auth Dependencies
// -------------------------

import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/session_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/session_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'domain/usecases/request_password_reset_usecase.dart';
import 'domain/usecases/resend_otp_usecase.dart';
import 'domain/usecases/reset_password_usecase.dart';
import 'domain/usecases/verify_otp_usecase.dart';
import 'presentation/create_new_password/cubit/create_new_password_cubit.dart';
import 'presentation/forgot_password/cubit/forgot_password_cubit.dart';
import 'presentation/login/cubit/login_cubit.dart';
import 'presentation/sign_up/cubit/sign_up_cubit.dart';
import 'presentation/verify_email/cubit/verify_email_cubit.dart';

/// تسجيل اعتماديات ميزة auth.
///
/// الميزة هي اللي بتسجّل حالها، فـ`core` ما بتستورد شي من `features`.
/// نقطة التركيب (`main.dart`) بتنادي هذا بعد اعتماديات الـ core.
void registerAuthDependencies(GetIt sl) {
  // -------------------------
  // Data
  // -------------------------

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sl<SecureStorageService>()),
  );

  // -------------------------
  // Domain
  // -------------------------

  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>(), sl<SessionRepository>()),
  );

  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<ResendOtpUseCase>(
    () => ResendOtpUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<RequestPasswordResetUseCase>(
    () => RequestPasswordResetUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl<AuthRepository>()),
  );

  // -------------------------
  // Presentation
  // -------------------------

  // factory مش singleton: كل دخول للشاشة بده Cubit بحالة نظيفة.

  sl.registerFactory<LoginCubit>(() => LoginCubit(sl<LoginUseCase>()));

  sl.registerFactory<SignUpCubit>(() => SignUpCubit(sl<RegisterUseCase>()));

  sl.registerFactory<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(sl<RequestPasswordResetUseCase>()),
  );

  // الشاشتان الجايتان بتاخدوا بيانات من المسار (البريد والرمز)،
  // فبتنبنوا بـ factoryParam بدل factory عادية.

  sl.registerFactoryParam<VerifyEmailCubit, String, void>(
    (email, _) => VerifyEmailCubit(
      sl<VerifyOtpUseCase>(),
      sl<ResendOtpUseCase>(),
      email: email,
    ),
  );

  sl.registerFactoryParam<CreateNewPasswordCubit, String, String>(
    (email, code) => CreateNewPasswordCubit(
      sl<ResetPasswordUseCase>(),
      email: email,
      code: code,
    ),
  );
}
