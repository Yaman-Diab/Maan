// -------------------------
// Update Skill Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/skill_type.dart';
import '../repositories/skills_repository.dart';

class UpdateSkillParams {
  final int skillId;
  final String name;
  final SkillType type;

  const UpdateSkillParams({
    required this.skillId,
    required this.name,
    required this.type,
  });
}

class UpdateSkillUseCase implements UseCase<void, UpdateSkillParams> {
  final SkillsRepository _repository;

  const UpdateSkillUseCase(this._repository);

  @override
  Future<Result<void>> call(UpdateSkillParams params) {
    return _repository.updateSkill(
      skillId: params.skillId,
      name: params.name,
      type: params.type,
    );
  }
}
