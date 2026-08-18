// -------------------------
// Vote Project Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/project_vote_receipt.dart';
import '../repositories/projects_repository.dart';

class VoteProjectParams extends Equatable {
  final int projectId;
  final bool value;

  const VoteProjectParams({required this.projectId, required this.value});

  @override
  List<Object?> get props => [projectId, value];
}

class VoteProjectUseCase
    implements UseCase<ProjectVoteReceipt, VoteProjectParams> {
  final ProjectsRepository _repository;

  const VoteProjectUseCase(this._repository);

  @override
  Future<Result<ProjectVoteReceipt>> call(VoteProjectParams params) {
    return _repository.vote(projectId: params.projectId, value: params.value);
  }
}
