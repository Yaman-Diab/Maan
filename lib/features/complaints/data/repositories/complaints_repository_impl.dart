// -------------------------
// Complaints Repository Impl
// -------------------------

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/media/picked_complaint_media.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/entities/complaint_category.dart';
import '../../domain/entities/complaint_report_reason.dart';
import '../../domain/entities/complaint_sort.dart';
import '../../domain/entities/complaint_type.dart';
import '../../domain/repositories/complaints_repository.dart';
import '../datasources/complaints_remote_data_source.dart';

class ComplaintsRepositoryImpl implements ComplaintsRepository {
  final ComplaintsRemoteDataSource _remoteDataSource;

  const ComplaintsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<Complaint>>> getPublished({
    ComplaintType? type,
    ComplaintCategory? category,
    required ComplaintSort sort,
    required int page,
    required int pageSize,
  }) {
    return _guard(
      () => _remoteDataSource.getPublished(
        type: type,
        category: category,
        sort: sort,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  @override
  Future<Result<List<Complaint>>> getMine({
    required int page,
    required int pageSize,
  }) {
    return _guard(
      () => _remoteDataSource.getMine(page: page, pageSize: pageSize),
    );
  }

  @override
  Future<Result<void>> submit({
    required ComplaintType type,
    required ComplaintCategory category,
    required String title,
    String? description,
    required double latitude,
    required double longitude,
    List<PickedComplaintMedia> media = const [],
  }) {
    return _guard(
      () => _remoteDataSource.submit(
        type: type,
        category: category,
        title: title,
        description: description,
        latitude: latitude,
        longitude: longitude,
        media: media,
      ),
    );
  }

  @override
  Future<Result<void>> vote(int complaintId) {
    return _guard(() => _remoteDataSource.vote(complaintId));
  }

  @override
  Future<Result<void>> unvote(int complaintId) {
    return _guard(() => _remoteDataSource.unvote(complaintId));
  }

  @override
  Future<Result<void>> report({
    required int complaintId,
    required ComplaintReportReason reason,
    required String description,
  }) {
    return _guard(
      () => _remoteDataSource.report(
        complaintId: complaintId,
        reason: reason,
        description: description,
      ),
    );
  }

  Future<Result<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return Ok(await operation());
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }
}
