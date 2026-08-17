// -------------------------
// Get Municipal Services Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/municipal_service.dart';
import '../repositories/municipal_services_repository.dart';

class GetMunicipalServicesUseCase
    implements UseCase<List<MunicipalService>, NoParams> {
  final MunicipalServicesRepository _repository;

  const GetMunicipalServicesUseCase(this._repository);

  @override
  Future<Result<List<MunicipalService>>> call(NoParams params) {
    return _repository.getServices();
  }
}
