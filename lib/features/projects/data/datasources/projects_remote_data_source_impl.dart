// -------------------------
// Projects Remote Data Source Impl
// -------------------------

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/municipal_project.dart';
import '../../domain/entities/project_donation_stats.dart';
import '../../domain/entities/project_vote_receipt.dart';
import '../models/municipal_project_model.dart';
import '../models/project_donation_stats_model.dart';
import '../models/project_vote_receipt_model.dart';
import 'projects_remote_data_source.dart';

class ProjectsRemoteDataSourceImpl implements ProjectsRemoteDataSource {
  final ApiClient _apiClient;

  const ProjectsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<MunicipalProject>> getProjects() async {
    final response = await _apiClient.request(
      endpoint: ApiEndpoints.projectVotable,
      method: ApiMethod.get,
    );

    return MunicipalProjectModel.listFromResponse(response);
  }

  @override
  Future<ProjectVoteReceipt> vote({
    required int projectId,
    required bool value,
  }) async {
    final response = await _apiClient.request(
      endpoint: ApiEndpoints.projectVote(projectId),
      method: ApiMethod.post,
      data: {'value': value},
    );

    return ProjectVoteReceiptModel.fromResponse(response).entity;
  }

  @override
  Future<void> unvote({required int projectId}) async {
    await _apiClient.request(
      endpoint: ApiEndpoints.projectVote(projectId),
      method: ApiMethod.delete,
    );
  }

  @override
  Future<ProjectDonationStats> getDonationStats(int projectId) async {
    final response = await _apiClient.request(
      endpoint: ApiEndpoints.projectDonationStats(projectId),
      method: ApiMethod.get,
    );

    return ProjectDonationStatsModel.fromResponse(response).entity;
  }

  /// ✅ `POST /api/project/volunteer/{id}` — حقيقي.
  ///
  /// ⚠️ اسم الحقل `whatsapp_number` لا `phone` — الرقم بينضاف لمجموعة
  /// واتساب التنسيق، والباك اند مسمّيه صراحةً هيك.
  @override
  Future<void> volunteer({
    required int projectId,
    required String phoneNumber,
  }) async {
    await _apiClient.request(
      endpoint: ApiEndpoints.projectVolunteer(projectId),
      method: ApiMethod.post,
      data: {'whatsapp_number': phoneNumber},
    );
  }
}
