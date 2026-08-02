// -------------------------
// Remove Avatar Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/profile_repository.dart';

/// إزالة الصورة الشخصية — راجع تحذير العقد بـ`ProfileRepository.removeAvatar`.
class RemoveAvatarUseCase implements UseCase<void, NoParams> {
  final ProfileRepository _repository;

  const RemoveAvatarUseCase(this._repository);

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.removeAvatar();
  }
}
