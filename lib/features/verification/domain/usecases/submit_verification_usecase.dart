// -------------------------
// Submit Verification Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/media/picked_image.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/verification_request.dart';
import '../repositories/verification_repository.dart';

final class SubmitVerificationParams extends Equatable {
  final String nationalId;
  final List<PickedImage> images;

  const SubmitVerificationParams({
    required this.nationalId,
    required this.images,
  });

  @override
  List<Object?> get props => [nationalId, images];
}

/// تقديم طلب توثيق الهوية.
///
/// تمرير مباشر لا تنسيق — على عكس `LoginUseCase` ما في خطوة ثانية بعد
/// النجاح (تحديث `AccountStatus` لسه `pending` لحد ما يوافق الباك اند،
/// فما في شي يتحدّث محلياً هلق).
class SubmitVerificationUseCase
    implements UseCase<VerificationRequest, SubmitVerificationParams> {
  final VerificationRepository _repository;

  const SubmitVerificationUseCase(this._repository);

  @override
  Future<Result<VerificationRequest>> call(SubmitVerificationParams params) {
    return _repository.submit(
      nationalId: params.nationalId,
      images: params.images,
    );
  }
}
