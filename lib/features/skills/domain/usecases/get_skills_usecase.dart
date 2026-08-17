// -------------------------
// Get Skills Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/skill.dart';
import '../repositories/skills_repository.dart';

class GetSkillsUseCase implements UseCase<List<Skill>, NoParams> {
  final SkillsRepository _repository;

  const GetSkillsUseCase(this._repository);

  @override
  Future<Result<List<Skill>>> call(NoParams params) {
    return _repository.getSkills();
  }
}
