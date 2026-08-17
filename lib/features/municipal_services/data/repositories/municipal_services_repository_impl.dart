// -------------------------
// Municipal Services Repository Impl
// -------------------------

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/municipal_service.dart';
import '../../domain/repositories/municipal_services_repository.dart';
import '../datasources/municipal_services_remote_data_source.dart';

class MunicipalServicesRepositoryImpl implements MunicipalServicesRepository {
  final MunicipalServicesRemoteDataSource _remoteDataSource;

  const MunicipalServicesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<MunicipalService>>> getServices() async {
    try {
      return Ok(await _remoteDataSource.getServices());
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }
}
