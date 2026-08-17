// -------------------------
// Skills Repository
// -------------------------

import '../../../../core/media/certificate_file_picker_service.dart';
import '../../../../core/result/result.dart';
import '../entities/skill.dart';
import '../entities/skill_type.dart';

abstract class SkillsRepository {
  /// مهارات المستخدم الحالي، كل وحدة مع شهادتها المرفقة إن وُجدت.
  ///
  /// بتدمج ردَّي `GET /api/skill/` و`GET /api/certificate` داخلياً —
  /// موردان منفصلان بالباك اند، بس الواجهة محتاجتهم مع بعض دايماً.
  Future<Result<List<Skill>>> getSkills();

  /// `POST /api/skill/store`.
  Future<Result<void>> addSkill({
    required String name,
    required SkillType type,
  });

  /// `POST /api/skill/update/{id}`.
  Future<Result<void>> updateSkill({
    required int skillId,
    required String name,
    required SkillType type,
  });

  /// `DELETE /api/skill/{id}`.
  Future<Result<void>> deleteSkill(int skillId);

  /// إرفاق أول شهادة لمهارة — `POST /api/certificate/store`.
  Future<Result<void>> attachCertificate({
    required int skillId,
    required PickedCertificateFile file,
  });

  /// استبدال شهادة قائمة (بما فيها المرفوضة) — `POST /api/certificate/update/{id}`.
  /// [certificateId] معرّف **الشهادة** لا المهارة.
  Future<Result<void>> replaceCertificate({
    required int certificateId,
    required PickedCertificateFile file,
  });
}
