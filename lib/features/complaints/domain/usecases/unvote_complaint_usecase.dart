// -------------------------
// Unvote Complaint Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/complaints_repository.dart';

class UnvoteComplaintUseCase implements UseCase<void, int> {
  final ComplaintsRepository _repository;

  const UnvoteComplaintUseCase(this._repository);

  @override
  Future<Result<void>> call(int complaintId) {
    return _repository.unvote(complaintId);
  }
}
