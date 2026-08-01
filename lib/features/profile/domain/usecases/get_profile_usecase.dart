// -------------------------
// Get Profile Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/citizen_profile.dart';
import '../repositories/profile_repository.dart';

/// جلب ملف المواطن.
///
/// بلا مدخلات: الباك اند بيعرف مين المستخدم من التوكن.
class GetProfileUseCase implements UseCase<CitizenProfile, NoParams> {
  final ProfileRepository _repository;

  const GetProfileUseCase(this._repository);

  @override
  Future<Result<CitizenProfile>> call(NoParams params) {
    return _repository.getProfile();
  }
}
