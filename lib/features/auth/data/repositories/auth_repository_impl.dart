// -------------------------
// Auth Repository Impl
// -------------------------

import 'package:easy_localization/easy_localization.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_status_codes.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';
import 'package:maan/core/domain/birth_date.dart';
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
  }) async {
    try {
      final response = await _remoteDataSource.login(
        LoginRequestModel(email: email, password: password),
      );

      return Ok(response.toEntity());
    } on ApiException catch (error) {
      // 401 هون معناها الوحيد المنطقي إن البريد أو كلمة المرور غلط —
      // ما في جلسة أصلاً قبل الدخول لتنتهي. الباك اند الحقيقي بيرجّع
      // هالحالة **بلا** حقل `code` (بس `message`)، فـ`FailureMapper`
      // العام ما بيميّزها عن 401 حقيقي لجلسة منتهية وبيرجع الرسالة
      // العامة «سجّل دخولك من جديد» غلط. التمييز هون لأنه معرفة خاصة
      // بـ endpoint الدخول، مش شي `FailureMapper` المشترك يقدر يعرفه.
      if (error.statusCode == ApiStatusCodes.unauthorized) {
        return Err(AuthFailure('error_invalid_credentials'.tr()));
      }

      return Err(FailureMapper.fromApiException(error));
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }

  @override
  Future<Result<void>> register({
    required String firstName,
    required String lastName,
    required BirthDate birthDate,
    required String nationalId,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _guardVoid(() {
      return _remoteDataSource.register(
        RegisterRequestModel(
          firstName: firstName,
          lastName: lastName,
          birthDate: birthDate.apiFormat,
          nationalId: nationalId,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        ),
      );
    });
  }

  @override
  Future<Result<void>> checkCode({required String code}) {
    return _guardVoid(() {
      return _remoteDataSource.checkCode(CheckCodeRequestModel(code: code));
    });
  }

  @override
  Future<Result<void>> resendVerification() {
    return _guardVoid(_remoteDataSource.resendVerification);
  }

  @override
  Future<Result<void>> forgetPassword({required String email}) {
    return _guardVoid(() {
      return _remoteDataSource.forgetPassword(
        ForgetPasswordRequestModel(email: email),
      );
    });
  }

  @override
  Future<Result<void>> resetPassword({
    required String code,
    required String password,
    required String passwordConfirmation,
  }) {
    return _guardVoid(() {
      return _remoteDataSource.resetPassword(
        ResetPasswordRequestModel(
          code: code,
          password: password,
          passwordConfirmation: passwordConfirmation,
        ),
      );
    });
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
