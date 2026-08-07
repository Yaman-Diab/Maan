// -------------------------
// Verification Request
// -------------------------

import 'package:equatable/equatable.dart';

import 'verification_request_status.dart';

/// صورة واحدة مرفوعة مع طلب التوثيق.
final class VerificationImage extends Equatable {
  final int id;
  final String imageUrl;

  const VerificationImage({required this.id, required this.imageUrl});

  @override
  List<Object?> get props => [id, imageUrl];
}

/// طلب توثيق هوية مقدَّم — الناتج من `POST /api/verification/store`.
///
/// صورتين **بالضبط** (مثلاً وجه الهوية وصورة شخصية) — قاعدة `size:2`
/// مؤكّدة من رسالة خطأ الباك اند الحقيقية، لا حد أدنى قابل للزيادة.
/// التحقق منها لسه مسؤولية الواجهة يوم تُبنى، لا هالكيان.
final class VerificationRequest extends Equatable {
  final int id;
  final int userId;
  final String nationalId;
  final VerificationRequestStatus status;
  final List<VerificationImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// سبب الرفض المُصنَّف (مثلاً `blurry_images`) — `null` لأي حالة غير
  /// [VerificationRequestStatus.rejected].
  ///
  /// ⚠️ **مخمَّن**: مصدره الوحيد جسم **طلب الأدمن**
  /// `POST /api/verification/reject/{id}` بـ`collection.md` (`reason` +
  /// `description`). إنه يرجع بنفس الاسمين **بقراءة المواطن** مفترَض لا
  /// مؤكّد. الواجهة بتتعامل مع الغياب بلطف: بتعرض نص رفض عام بدل ما
  /// تفترض وجوده.
  final String? rejectionReason;

  /// شرح الرفض الحر اللي بيكتبه الموظّف — اختياري حتى بعقد الأدمن نفسه.
  final String? rejectionDescription;

  const VerificationRequest({
    required this.id,
    required this.userId,
    required this.nationalId,
    required this.status,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    this.rejectionReason,
    this.rejectionDescription,
  });

  /// الطلب «فعّال» لما يكون لسه قيد المراجعة — الحالة الوحيدة اللي
  /// بتسمح بتصحيح الرقم الوطني عبر `POST /api/verification/update`.
  bool get isEditable => status.isPending;

  @override
  List<Object?> get props => [
    id,
    userId,
    nationalId,
    status,
    images,
    createdAt,
    updatedAt,
    rejectionReason,
    rejectionDescription,
  ];
}
