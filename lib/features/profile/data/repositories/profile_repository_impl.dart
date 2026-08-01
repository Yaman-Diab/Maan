// -------------------------
// Profile Repository Impl
// -------------------------

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/citizen_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

/// حدّ التحويل: استثناءات الشبكة بتدخل، و[Result] بيطلع.
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  const ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<CitizenProfile>> getProfile() async {
    try {
      final model = await _remoteDataSource.getProfile();

      return Ok(model.toEntity());
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }
}
