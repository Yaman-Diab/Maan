// -------------------------
// Projects Remote Data Source
// -------------------------

import '../../domain/entities/municipal_project.dart';
import '../../domain/entities/project_donation_stats.dart';
import '../../domain/entities/project_vote_receipt.dart';

abstract class ProjectsRemoteDataSource {
  /// ✅ `GET /api/project/votable` — حقيقي.
  Future<List<MunicipalProject>> getProjects();

  /// ⚠️ **بلا endpoint بعد** — راجع `ProjectsRemoteDataSourceImpl.volunteer`.
  Future<void> volunteer({required int projectId, required String phoneNumber});

  /// ✅ `POST /api/project/vote/{id}` — حقيقي.
  Future<ProjectVoteReceipt> vote({
    required int projectId,
    required bool value,
  });

  /// ✅ `DELETE /api/project/vote/{id}` — حقيقي.
  Future<void> unvote({required int projectId});

  /// ✅ `GET /api/project/{id}/donations/stats` — حقيقي.
  Future<ProjectDonationStats> getDonationStats(int projectId);

  /// ✅ `GET /api/project/{id}` — حقيقي، citizen-accessible. مصدر
  /// `imageUrl`/`location`/`requiresVolunteers`/`requiresDonations`
  /// يلي `getProjects()` ما بيرجّعهم.
  Future<MunicipalProject> getProjectDetail(int projectId);
}
