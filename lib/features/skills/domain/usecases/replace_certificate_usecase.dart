// -------------------------
// Replace Certificate Use Case
// -------------------------

import '../../../../core/media/certificate_file_picker_service.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/skills_repository.dart';

class ReplaceCertificateParams {
  final int certificateId;
  final PickedCertificateFile file;

  const ReplaceCertificateParams({
    required this.certificateId,
    required this.file,
  });
}

class ReplaceCertificateUseCase
    implements UseCase<void, ReplaceCertificateParams> {
  final SkillsRepository _repository;

  const ReplaceCertificateUseCase(this._repository);

  @override
  Future<Result<void>> call(ReplaceCertificateParams params) {
    return _repository.replaceCertificate(
      certificateId: params.certificateId,
      file: params.file,
    );
  }
}
