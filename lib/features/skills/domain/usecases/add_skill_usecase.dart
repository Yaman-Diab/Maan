// -------------------------
// Add Skill Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/skill_type.dart';
import '../repositories/skills_repository.dart';

class AddSkillParams {
  final String name;
  final SkillType type;

  const AddSkillParams({required this.name, required this.type});
}

class AddSkillUseCase implements UseCase<void, AddSkillParams> {
  final SkillsRepository _repository;

  const AddSkillUseCase(this._repository);

  @override
  Future<Result<void>> call(AddSkillParams params) {
    return _repository.addSkill(name: params.name, type: params.type);
  }
}
