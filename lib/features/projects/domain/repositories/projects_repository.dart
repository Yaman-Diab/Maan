// -------------------------
// Projects Repository
// -------------------------

import '../../../../core/result/result.dart';
import '../entities/municipal_project.dart';
import '../entities/project_vote_receipt.dart';

abstract class ProjectsRepository {
  /// المشاريع القابلة للتصويت — `GET /api/project/votable`.
  Future<Result<List<MunicipalProject>>> getProjects();

  /// تسجيل طلب تطوع برقم هاتف — الرقم بينضاف لمجموعة واتساب التنسيق.
  ///
  /// ⚠️ بلا عقد باك اند. الموافقة على الطلب بتصير عند موظّف البلدية
  /// لاحقاً، فالنجاح هون معناه «انبعت الطلب» لا «انقبلت».
  Future<Result<void>> volunteer({
    required int projectId,
    required String phoneNumber,
  });

  /// تصويت — `POST /api/project/vote/{id}`، `value: true` = أحبذ،
  /// `false` = لا أحبذ.
  ///
  /// ⚠️ **بلا تصويت ثانٍ مباشر** — محاولة `POST` على مشروع صوّتنا
  /// عليه أصلاً (حتى بنفس القيمة) بترجع فشلاً (`409`). التبديل لازم
  /// يمرّ بـ[unvote] أول.
  Future<Result<ProjectVoteReceipt>> vote({
    required int projectId,
    required bool value,
  });

  /// سحب التصويت — `DELETE /api/project/vote/{id}`.
  Future<Result<void>> unvote({required int projectId});
}
