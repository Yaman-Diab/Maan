// -------------------------
// Report Complaint Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/complaint_report_reason.dart';
import '../repositories/complaints_repository.dart';

class ReportComplaintParams {
  final int complaintId;
  final ComplaintReportReason reason;
  final String description;

  const ReportComplaintParams({
    required this.complaintId,
    required this.reason,
    required this.description,
  });
}

class ReportComplaintUseCase implements UseCase<void, ReportComplaintParams> {
  final ComplaintsRepository _repository;

  const ReportComplaintUseCase(this._repository);

  @override
  Future<Result<void>> call(ReportComplaintParams params) {
    return _repository.report(
      complaintId: params.complaintId,
      reason: params.reason,
      description: params.description,
    );
  }
}
