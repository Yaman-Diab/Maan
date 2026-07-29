// -------------------------
// Auth Repository Impl
// -------------------------

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/birth_date.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_request_models.dart';
import '../models/login_request_model.dart';

/// حدّ التحويل: استثناءات الشبكة بتدخل، و[Result] بيطلع.
///
/// بعد هالنقطة ما بتشوف طبقة الـ domain ولا الـ presentation أي
/// `ApiException` — وهذا اللي بيوحّد معالجة الأخطاء عبر كل الفلوز.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final response = await _remoteDataSource.login(
        LoginRequestModel(email: email, password: password),
      );

      return response.toEntity();
    });
  }

  @override
  Future<Result<void>> register({
    required String firstName,
    required String lastName,
    required BirthDate birthDate,
    required String email,
    required String password,
  }) {
    return _guardVoid(() {
      return _remoteDataSource.register(
        RegisterRequestModel(
          firstName: firstName,
          lastName: lastName,
          birthday: birthDate.formatted,
          email: email,
          password: password,
        ),
      );
    });
  }

  @override
  Future<Result<void>> verifyOtp({
    required String email,
    required String code,
  }) {
    return _guardVoid(() {
      return _remoteDataSource.verifyOtp(
        VerifyOtpRequestModel(email: email, code: code),
      );
    });
  }

  @override
  Future<Result<void>> resendOtp({required String email}) {
    return _guardVoid(() {
      return _remoteDataSource.resendOtp(ResendOtpRequestModel(email: email));
    });
  }

  @override
  Future<Result<void>> requestPasswordReset({required String email}) {
    return _guardVoid(() {
      return _remoteDataSource.requestPasswordReset(
        RequestPasswordResetRequestModel(email: email),
      );
    });
  }

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String code,
    required String password,
  }) {
    return _guardVoid(() {
      return _remoteDataSource.resetPassword(
        ResetPasswordRequestModel(
          email: email,
          code: code,
          password: password,
        ),
      );
    });
  }

  /// كل الميثودات بتتشارك نفس حدّ الأمان، فما ينكرر try/catch ست مرات.
  Future<Result<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return Ok(await operation());
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }

  /// نسخة للعمليات اللي ما بترجّع قيمة — `Ok(await ...)` ما بتشتغل مع `void`.
  Future<Result<void>> _guardVoid(Future<void> Function() operation) async {
    try {
      await operation();
      return const Ok<void>(null);
    } catch (error) {
      return Err<void>(FailureMapper.fromError(error));
    }
  }
}
