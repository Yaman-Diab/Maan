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

  /// المشاريع + تفاصيلها الكاملة + إحصائيات تبرعاتها، مدموجة بطبقة
  /// data — نفس نمط `SkillsRepositoryImpl.getSkills()` (مهارات +
  /// شهادات من مسارين بالتوازي).
  ///
  /// ⚠️ **طلبان إضافيان لكل مشروع بلا استثناء** — `GET /api/project/votable`
  /// **ما بيرجّع** `image`/`location`/`is_voluntary`/`is_donation`/
  /// `type`/`status`/`is_votable`/`budget`/`requirements` إطلاقاً (غياب
  /// قاطع، مؤكّد من كود الباك اند: `listVotable()` بيبني مصفوفة استجابة
  /// يدوية بـ13 مفتاح بالضبط)، وإحصائيات التبرعات endpoint منفصل
  /// أساساً — فما في طريقة نجيب أي منهم بطلب القائمة الواحد.
  /// `_detailOrNull`/`_donationStatsOrNull` بيتنفّذوا بالتوازي لكل
  /// مشروع (كل طلب بيمسك خطأه لحاله، بلا ما يكسر البقية أو يوقّف
  /// القائمة).
  @override
  Future<Result<List<MunicipalProject>>> getProjects() async {
    try {
      final projects = await _remoteDataSource.getProjects();
      final merged = await Future.wait(projects.map(_withDetailAndStats));

      return Ok(merged);
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }

  Future<MunicipalProject> _withDetailAndStats(MunicipalProject project) async {
    // كلا الطلبين بيبلّشوا فوراً (مهام غير منتظَرة بعد)، فبيمشوا
    // بالتوازي رغم إن الانتظار تسلسلي بالكود.
    final detailFuture = _detailOrNull(project.id);
    final statsFuture = _donationStatsOrNull(project.id);

    final detail = await detailFuture;
    final stats = await statsFuture;

    var merged = project;

    if (detail != null) {
      merged = merged.copyWith(
        imageUrl: detail.imageUrl,
        latitude: detail.latitude,
        longitude: detail.longitude,
        type: detail.type,
        status: detail.status,
        isVotable: detail.isVotable,
        budget: detail.budget,
        requirements: detail.requirements,
        requiresVolunteers: detail.requiresVolunteers,
        volunteersNeeded: detail.volunteersNeeded,
        volunteersApproved: detail.volunteersApproved,
        requiresDonations: detail.requiresDonations,
      );
    }

    if (stats != null) {
      merged = merged.copyWith(donationStats: stats);
    }

    return merged;
  }

  Future<MunicipalProject?> _detailOrNull(int projectId) async {
    try {
      return await _remoteDataSource.getProjectDetail(projectId);
    } catch (_) {
      return null;
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
