// -------------------------
// Get Verification Status Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/verification_request.dart';
import '../repositories/verification_repository.dart';

/// آخر طلب توثيق للمستخدم — `null` يعني ما قدّم ولا طلب بعد.
///
/// بتنادى مرّة وقت فتح الشاشة عشان تقرّر أي عرض يظهر (نموذج / قيد
/// المراجعة / مرفوض / معتمد). `NoParams` لأن الباك اند بيحدّد المستخدم
/// من التوكن متل `GetProfileUseCase`.
class GetVerificationStatusUseCase
    implements UseCase<VerificationRequest?, NoParams> {
  final VerificationRepository _repository;

  const GetVerificationStatusUseCase(this._repository);

  @override
  Future<Result<VerificationRequest?>> call(NoParams params) {
    return _repository.latestRequest();
  }
}
