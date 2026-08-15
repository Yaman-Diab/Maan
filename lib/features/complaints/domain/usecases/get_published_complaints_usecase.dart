// -------------------------
// Get Published Complaints Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/complaint.dart';
import '../entities/complaint_category.dart';
import '../entities/complaint_sort.dart';
import '../entities/complaint_type.dart';
import '../repositories/complaints_repository.dart';

class GetPublishedComplaintsParams {
  final ComplaintType? type;
  final ComplaintCategory? category;
  final ComplaintSort sort;
  final int page;
  final int pageSize;

  const GetPublishedComplaintsParams({
    this.type,
    this.category,
    required this.sort,
    required this.page,
    required this.pageSize,
  });
}

class GetPublishedComplaintsUseCase
    implements UseCase<List<Complaint>, GetPublishedComplaintsParams> {
  final ComplaintsRepository _repository;

  const GetPublishedComplaintsUseCase(this._repository);

  @override
  Future<Result<List<Complaint>>> call(GetPublishedComplaintsParams params) {
    return _repository.getPublished(
      type: params.type,
      category: params.category,
      sort: params.sort,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}
