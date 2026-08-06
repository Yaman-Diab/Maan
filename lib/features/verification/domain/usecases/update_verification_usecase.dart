// -------------------------
// Update Verification Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/verification_request.dart';
import '../repositories/verification_repository.dart';

final class UpdateVerificationParams extends Equatable {
  final int requestId;
  final String nationalId;

  const UpdateVerificationParams({
    required this.requestId,
    required this.nationalId,
  });

  @override
  List<Object?> get props => [requestId, nationalId];
}

/// تصحيح رقم وطني بطلب توثيق قائم لسه `pending` — راجع تحذير العقد
/// بـ`VerificationRepository.update`.
class UpdateVerificationUseCase
    implements UseCase<VerificationRequest, UpdateVerificationParams> {
  final VerificationRepository _repository;

  const UpdateVerificationUseCase(this._repository);

  @override
  Future<Result<VerificationRequest>> call(UpdateVerificationParams params) {
    return _repository.update(
      requestId: params.requestId,
      nationalId: params.nationalId,
    );
  }
}
