// -------------------------
// Unvote Project Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/projects_repository.dart';

class UnvoteProjectParams extends Equatable {
  final int projectId;

  const UnvoteProjectParams({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class UnvoteProjectUseCase implements UseCase<void, UnvoteProjectParams> {
  final ProjectsRepository _repository;

  const UnvoteProjectUseCase(this._repository);

  @override
  Future<Result<void>> call(UnvoteProjectParams params) {
    return _repository.unvote(projectId: params.projectId);
  }
}
