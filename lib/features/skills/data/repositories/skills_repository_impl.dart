// -------------------------
// Skills Repository Impl
// -------------------------

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/media/certificate_file_picker_service.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/skill_type.dart';
import '../../domain/repositories/skills_repository.dart';
import '../datasources/skills_remote_data_source.dart';

class SkillsRepositoryImpl implements SkillsRepository {
  final SkillsRemoteDataSource _remoteDataSource;

  const SkillsRepositoryImpl(this._remoteDataSource);

  /// موردان منفصلان بالباك اند — بنجيبهم بالتوازي وبندمجهم هون لأنها
  /// المكان الصح الوحيد اللي بيعرف شكل الاثنين مع بعض؛ الـdomain ما
  /// بيعرف شي عن وجود endpoint منفصل للشهادات أصلاً.
  @override
  Future<Result<List<Skill>>> getSkills() async {
    try {
      // ما بننتظر وحدة قبل التانية — الطلبان بيصيرا بالتوازي.
      final skillsFuture = _remoteDataSource.getSkills();
      final certificatesFuture = _remoteDataSource.getCertificates();

      final skills = await skillsFuture;
      final certificates = await certificatesFuture;

      final merged = [
        for (final skill in skills)
          Skill(
            id: skill.id,
            name: skill.name,
            type: skill.type,
            createdAt: skill.createdAt,
            certificate: certificates.firstWhereOrNull(
              (cert) => cert.skillId == skill.id,
            ),
          ),
      ];

      return Ok(merged);
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }

  @override
  Future<Result<void>> addSkill({
    required String name,
    required SkillType type,
  }) {
    return _guard(() => _remoteDataSource.addSkill(name: name, type: type));
  }

  @override
  Future<Result<void>> updateSkill({
    required int skillId,
    required String name,
    required SkillType type,
  }) {
    return _guard(
      () => _remoteDataSource.updateSkill(
        skillId: skillId,
        name: name,
        type: type,
      ),
    );
  }

  @override
  Future<Result<void>> deleteSkill(int skillId) {
    return _guard(() => _remoteDataSource.deleteSkill(skillId));
  }

  @override
  Future<Result<void>> attachCertificate({
    required int skillId,
    required PickedCertificateFile file,
  }) {
    return _guard(
      () => _remoteDataSource.attachCertificate(skillId: skillId, file: file),
    );
  }

  @override
  Future<Result<void>> replaceCertificate({
    required int certificateId,
    required PickedCertificateFile file,
  }) {
    return _guard(
      () => _remoteDataSource.replaceCertificate(
        certificateId: certificateId,
        file: file,
      ),
    );
  }

  Future<Result<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return Ok(await operation());
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }
}

extension _FirstWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }

    return null;
  }
}
