// -------------------------
// Municipal Services Remote Data Source
// -------------------------

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/municipal_service.dart';
import '../models/municipal_service_model.dart';

/// المكان الوحيد اللي بيعرف Dio وendpoint خدمات البلدية.
abstract class MunicipalServicesRemoteDataSource {
  Future<List<MunicipalService>> getServices();
}

class MunicipalServicesRemoteDataSourceImpl
    implements MunicipalServicesRemoteDataSource {
  final ApiClient _apiClient;

  const MunicipalServicesRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<MunicipalService>> getServices() async {
    final response = await _apiClient.request(
      endpoint: ApiEndpoints.municipalServicesIndex,
      method: ApiMethod.get,
    );

    return MunicipalServiceModel.listFromResponse(response);
  }
}
