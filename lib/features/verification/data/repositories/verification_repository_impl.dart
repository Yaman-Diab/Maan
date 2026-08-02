// -------------------------
// Verification Repository Impl
// -------------------------

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/media/picked_image.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/verification_request.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource _remoteDataSource;

  const VerificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<VerificationRequest>> submit({
    required String nationalId,
    required List<PickedImage> images,
  }) async {
    try {
      final model = await _remoteDataSource.submit(
        nationalId: nationalId,
        images: images,
      );

      return Ok(model.toEntity());
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }
}
