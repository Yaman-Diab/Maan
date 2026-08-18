// -------------------------
// Get Projects Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/municipal_project.dart';
import '../repositories/projects_repository.dart';

class GetProjectsUseCase implements UseCase<List<MunicipalProject>, NoParams> {
  final ProjectsRepository _repository;

  const GetProjectsUseCase(this._repository);

  @override
  Future<Result<List<MunicipalProject>>> call(NoParams params) {
    return _repository.getProjects();
  }
}
