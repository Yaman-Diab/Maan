// -------------------------
// Projects Repository Impl
// -------------------------

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/municipal_project.dart';
import '../../domain/entities/project_donation_stats.dart';
import '../../domain/entities/project_vote_receipt.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_remote_data_source.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsRemoteDataSource _remoteDataSource;

  const ProjectsRepositoryImpl(this._remoteDataSource);

  /// المشاريع + إحصائيات تبرعاتها، مدموجة بطبقة data — نفس نمط
  /// `SkillsRepositoryImpl.getSkills()` (مهارات + شهادات من مسارين
  /// بالتوازي).
  ///
  /// ⚠️ **طلب لكل مشروع** — الإحصائيات endpoint منفصل لكل `id`، فما في
  /// طريقة نجيبها بطلب واحد. التخفيف: بتنجلب **بس** للمشاريع اللي
  /// `requiresDonations` (الباقي ما بيعرض شريط تبرعات أصلاً)،
  /// وبالتوازي لا بالتتابع. لو الباك اند ضمّن الإحصائيات بـ
  /// `GET /api/project/votable` لاحقاً، هالدمج بينشال كامل ويتقرأ
  /// الحقل مباشرة بـ`MunicipalProjectModel`.
  ///
  /// ⚠️ **فشل الإحصائيات ما بيكسر القائمة** — كل طلب بيمسك خطأه
  /// وبيرجّع `null`، فالمشروع بيوصل بلا شريط تقدّم بدل ما تفشل الشاشة
  /// كلها. نفس فلسفة استقلال الأقسام بالرئيسية.
  @override
  Future<Result<List<MunicipalProject>>> getProjects() async {
    try {
      final projects = await _remoteDataSource.getProjects();

      final withStats = await Future.wait(
        projects.map((project) async {
          if (!project.requiresDonations) return project;

          final stats = await _donationStatsOrNull(project.id);

          return stats == null
              ? project
              : project.copyWith(donationStats: stats);
        }),
      );

      return Ok(withStats);
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }

  Future<ProjectDonationStats?> _donationStatsOrNull(int projectId) async {
    try {
      return await _remoteDataSource.getDonationStats(projectId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<void>> volunteer({
    required int projectId,
    required String phoneNumber,
  }) async {
    try {
      await _remoteDataSource.volunteer(
        projectId: projectId,
        phoneNumber: phoneNumber,
      );

      return const Ok(null);
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }

  @override
  Future<Result<ProjectVoteReceipt>> vote({
    required int projectId,
    required bool value,
  }) async {
    try {
      return Ok(
        await _remoteDataSource.vote(projectId: projectId, value: value),
      );
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }

  @override
  Future<Result<void>> unvote({required int projectId}) async {
    try {
      await _remoteDataSource.unvote(projectId: projectId);

      return const Ok(null);
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }
}
