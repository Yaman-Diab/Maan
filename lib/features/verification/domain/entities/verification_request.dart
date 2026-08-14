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
  /// ⚠️ **مخمَّن جزئياً**: `GET /api/verification` الحقيقي بيرجّع
  /// مصفوفة `rejections` منفصلة على كل طلب (تأكّدنا منها — كانت فاضية
  /// بمثالنا لأن الطلب لسه `pending`)، فمصدر السبب على الأغلب عنصر
  /// جوّاها لا حقلين مسطّحين على الطلب نفسه كما كنا نفترض. بس **شكل
  /// عنصر الرفض لسه غير مؤكّد** (ما وصلنا مثال برفض حقيقي) — فـ
  /// `VerificationRequestModel.fromMap` بتضل تجرّب `reason`/`description`
  /// مسطّحين كخط دفاع أول (نفس شكل جسم طلب الأدمن)، والواجهة بتتعامل
  /// مع الغياب بلطف بعرض نص رفض عام. نقطة التصحيح لما يوصل مثال حقيقي:
  /// `VerificationRequestModel.fromMap`.
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
