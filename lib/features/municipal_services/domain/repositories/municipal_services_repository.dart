// -------------------------
// Municipal Services Repository
// -------------------------

import '../../../../core/result/result.dart';
import '../entities/municipal_service.dart';

abstract class MunicipalServicesRepository {
  /// `GET /api/admin/services`.
  Future<Result<List<MunicipalService>>> getServices();
}
