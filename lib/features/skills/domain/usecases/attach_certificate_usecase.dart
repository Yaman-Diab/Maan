// -------------------------
// Attach Certificate Use Case
// -------------------------

import '../../../../core/media/certificate_file_picker_service.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/skills_repository.dart';

class AttachCertificateParams {
  final int skillId;
  final PickedCertificateFile file;

  const AttachCertificateParams({required this.skillId, required this.file});
}

class AttachCertificateUseCase
    implements UseCase<void, AttachCertificateParams> {
  final SkillsRepository _repository;

  const AttachCertificateUseCase(this._repository);

  @override
  Future<Result<void>> call(AttachCertificateParams params) {
    return _repository.attachCertificate(
      skillId: params.skillId,
      file: params.file,
    );
  }
}
