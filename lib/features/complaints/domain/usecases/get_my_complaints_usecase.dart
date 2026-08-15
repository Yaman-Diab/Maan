// -------------------------
// Get My Complaints Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/complaint.dart';
import '../repositories/complaints_repository.dart';

class GetMyComplaintsParams {
  final int page;
  final int pageSize;

  const GetMyComplaintsParams({required this.page, required this.pageSize});
}

class GetMyComplaintsUseCase
    implements UseCase<List<Complaint>, GetMyComplaintsParams> {
  final ComplaintsRepository _repository;

  const GetMyComplaintsUseCase(this._repository);

  @override
  Future<Result<List<Complaint>>> call(GetMyComplaintsParams params) {
    return _repository.getMine(page: params.page, pageSize: params.pageSize);
  }
}
