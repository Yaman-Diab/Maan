// -------------------------
// Complaints Repository
// -------------------------

import '../../../../core/media/picked_complaint_media.dart';
import '../../../../core/result/result.dart';
import '../entities/complaint.dart';
import '../entities/complaint_category.dart';
import '../entities/complaint_report_reason.dart';
import '../entities/complaint_sort.dart';
import '../entities/complaint_type.dart';

abstract class ComplaintsRepository {
  /// الشكاوى المنشورة — `GET /api/complains/complains`.
  ///
  /// [hasMore] بترجع `true` لو عدد العناصر المرجَّعة ساوى [pageSize]
  /// المطلوب (لا وسيط عدد صفحات مؤكّد بالاستجابة).
  Future<Result<List<Complaint>>> getPublished({
    ComplaintType? type,
    ComplaintCategory? category,
    required ComplaintSort sort,
    required int page,
    required int pageSize,
  });

  /// شكاوى المستخدم الحالي — `GET /api/complains/my-complains`.
  Future<Result<List<Complaint>>> getMine({
    required int page,
    required int pageSize,
  });

  /// تقديم شكوى جديدة — `POST /api/complains` (multipart).
  ///
  /// [latitude]/[longitude] إلزاميان لكل الأنواع. [description] إلزامي
  /// للفردية والجماعية بس — يحدَّد بالواجهة، هالميثود ما بتفحص.
  Future<Result<void>> submit({
    required ComplaintType type,
    required ComplaintCategory category,
    required String title,
    String? description,
    required double latitude,
    required double longitude,
    List<PickedComplaintMedia> media = const [],
  });

  /// تصويت — `POST /api/complains/vote`.
  Future<Result<void>> vote(int complaintId);

  /// إلغاء تصويت — `DELETE /api/complains/vote`.
  Future<Result<void>> unvote(int complaintId);

  /// الإبلاغ عن شكوى — `POST /api/reports`.
  Future<Result<void>> report({
    required int complaintId,
    required ComplaintReportReason reason,
    required String description,
  });
}
