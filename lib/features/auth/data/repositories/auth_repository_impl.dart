// -------------------------
// Auth Repository Impl
// -------------------------

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
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
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }
}
