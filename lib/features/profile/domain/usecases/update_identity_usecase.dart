// -------------------------
// Update Identity Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import 'package:maan/core/domain/birth_date.dart';
import '../repositories/profile_repository.dart';

final class UpdateIdentityParams {
  final String firstName;
  final String lastName;
  final String nationalId;
  final BirthDate birthDate;

  const UpdateIdentityParams({
    required this.firstName,
    required this.lastName,
    required this.nationalId,
    required this.birthDate,
  });
}

/// تحديث بيانات الهوية الأساسية — متاح للزائر وغير الموثّق بس، راجع
/// تحذير العقد بـ`ProfileRepository.updateIdentity`.
class UpdateIdentityUseCase implements UseCase<void, UpdateIdentityParams> {
  final ProfileRepository _repository;

  const UpdateIdentityUseCase(this._repository);

  @override
  Future<Result<void>> call(UpdateIdentityParams params) {
    return _repository.updateIdentity(
      firstName: params.firstName,
      lastName: params.lastName,
      nationalId: params.nationalId,
      birthDate: params.birthDate,
    );
  }
}
