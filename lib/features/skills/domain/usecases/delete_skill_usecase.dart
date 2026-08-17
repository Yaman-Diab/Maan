// -------------------------
// Delete Skill Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/skills_repository.dart';

class DeleteSkillUseCase implements UseCase<void, int> {
  final SkillsRepository _repository;

  const DeleteSkillUseCase(this._repository);

  @override
  Future<Result<void>> call(int skillId) {
    return _repository.deleteSkill(skillId);
  }
}
