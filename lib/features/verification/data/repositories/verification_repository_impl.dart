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
  Future<Result<VerificationRequest?>> latestRequest() {
    return _guard(() async {
      final models = await _remoteDataSource.index();

      if (models.isEmpty) return null;

      // الأحدث بـ`createdAt` لا أول عنصر: ترتيب الباك اند غير مضمون،
      // ومستخدم انرفض طلبه وأعاد الإرسال بيصير عنده أكتر من طلب.
      final entities = models.map((model) => model.toEntity()).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return entities.first;
    });
  }

  @override
  Future<Result<VerificationRequest>> submit({
    required String nationalId,
    required List<PickedImage> images,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.submit(
        nationalId: nationalId,
        images: images,
      );

      return model.toEntity();
    });
  }

  @override
  Future<Result<VerificationRequest>> update({
    required int requestId,
    required String nationalId,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.update(
        requestId: requestId,
        nationalId: nationalId,
      );

      return model.toEntity();
    });
  }

  Future<Result<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return Ok(await operation());
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }
}
