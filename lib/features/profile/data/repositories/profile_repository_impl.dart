// -------------------------
// Profile Repository Impl
// -------------------------

import 'dart:typed_data';

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
  Future<Result<CitizenProfile>> getProfile() {
    return _guard(() async {
      final model = await _remoteDataSource.getProfile();

      return model.toEntity();
    });
  }

  @override
  Future<Result<String?>> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) {
    return _guard(() {
      return _remoteDataSource.uploadAvatar(bytes: bytes, fileName: fileName);
    });
  }

  @override
  Future<Result<void>> removeAvatar() {
    return _guard(_remoteDataSource.removeAvatar);
  }

  Future<Result<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return Ok(await operation());
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }
}
