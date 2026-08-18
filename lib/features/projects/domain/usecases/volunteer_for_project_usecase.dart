// -------------------------
// Volunteer For Project Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/projects_repository.dart';

class VolunteerForProjectParams {
  final int projectId;
  final String phoneNumber;

  const VolunteerForProjectParams({
    required this.projectId,
    required this.phoneNumber,
  });
}

class VolunteerForProjectUseCase
    implements UseCase<void, VolunteerForProjectParams> {
  final ProjectsRepository _repository;

  const VolunteerForProjectUseCase(this._repository);

  @override
  Future<Result<void>> call(VolunteerForProjectParams params) {
    return _repository.volunteer(
      projectId: params.projectId,
      phoneNumber: params.phoneNumber,
    );
  }
}
