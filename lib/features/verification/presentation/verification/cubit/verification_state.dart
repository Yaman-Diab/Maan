// -------------------------
// Verification State
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../../core/media/picked_image.dart';
import '../../../../auth/domain/entities/auth_user.dart';
import '../../../domain/entities/verification_request.dart';

/// أي عرض من التصميم معروض حالياً.
///
/// [loading] أول ما تُفتح الشاشة لحد ما يرد `GET /api/verification`،
/// و[loadFailure] لو ما رد — بلاها الشاشة رح تعرض النموذج لمستخدم عنده
/// طلب `pending` أصلاً فيرسل طلب مكرّر بلا ما يدري.
enum VerificationView {
  loading,
  loadFailure,
  form,
  pending,
  rejected,
  approved,
}

/// حالة عمليات الإرسال/التصحيح — منفصلة عن [VerificationView] لأن
/// الإرسال بيصير **فوق** عرض قائم (النموذج بيضل ظاهر وقت التحميل).
enum VerificationSubmission { idle, submitting, success, failure }

/// خانة صورة وحدة بالنموذج. اثنتان بالضبط — قاعدة `size:2` المؤكّدة من
/// الباك اند (راجع `VerificationRepository.submit`).
enum DocumentSlot { front, selfie }

final class VerificationState extends Equatable {
  final VerificationView view;
  final VerificationSubmission submission;

  /// الطلب القائم — `null` بعرض [VerificationView.form] الأول.
  final VerificationRequest? request;

  /// بيانات المستخدم لبطاقة «البيانات الشخصية» (عرض فقط + زر تعديل
  /// بينقل لشاشة تعديل الهوية). `null` لو فشلت قراءة الملف الشخصي —
  /// البطاقة بتختفي وقتها بدل ما تعرض حقول فاضية، والتوثيق بيضل شغّال
  /// لأنه ما بيعتمد عليها.
  final AuthUser? user;

  final String nationalId;

  /// الصور المختارة محلياً قبل الرفع. `null` = الخانة فاضية.
  final PickedImage? frontImage;
  final PickedImage? selfieImage;

  final String? errorMessage;

  const VerificationState({
    this.view = VerificationView.loading,
    this.submission = VerificationSubmission.idle,
    this.request,
    this.user,
    this.nationalId = '',
    this.frontImage,
    this.selfieImage,
    this.errorMessage,
  });

  bool get isSubmitting => submission == VerificationSubmission.submitting;

  bool get hasBothImages => frontImage != null && selfieImage != null;

  PickedImage? imageFor(DocumentSlot slot) {
    return switch (slot) {
      DocumentSlot.front => frontImage,
      DocumentSlot.selfie => selfieImage,
    };
  }

  /// وضع «تصحيح رقم وطني» — طلب قائم قيد المراجعة والمستخدم رجع للنموذج
  /// عبر زر التعديل. الصور **مش مطلوبة** لأن العقد المؤكّد لـ
  /// `POST /api/verification/update` هو `id` + `national_id` بس (راجع
  /// `VerificationRepository.update`).
  bool get isEditingExisting =>
      view == VerificationView.form && (request?.isEditable ?? false);

  /// الحد الأدنى للرقم الوطني. الباك اند ما وثّق طول محدد، والتصميم
  /// بيقبل من 6 خانات — فبنمشي على التصميم بدل ما نخترع قاعدة.
  static const int minNationalIdLength = 6;

  bool get isNationalIdValid => nationalId.trim().length >= minNationalIdLength;

  bool get canSubmit {
    if (isSubmitting || !isNationalIdValid) return false;

    // بوضع التصحيح الصور مرفوعة أصلاً وما بتنبعت من جديد.
    return isEditingExisting || hasBothImages;
  }

  VerificationState copyWith({
    VerificationView? view,
    VerificationSubmission? submission,
    VerificationRequest? request,
    AuthUser? user,
    String? nationalId,
    PickedImage? frontImage,
    PickedImage? selfieImage,
    String? errorMessage,
    bool clearFrontImage = false,
    bool clearSelfieImage = false,
    bool clearRequest = false,
  }) {
    return VerificationState(
      view: view ?? this.view,
      submission: submission ?? this.submission,
      request: clearRequest ? null : (request ?? this.request),
      user: user ?? this.user,
      nationalId: nationalId ?? this.nationalId,
      frontImage: clearFrontImage ? null : (frontImage ?? this.frontImage),
      selfieImage: clearSelfieImage ? null : (selfieImage ?? this.selfieImage),
      // ما بتُورَّث: كل حالة بتصرّح بخطئها فما بيعلق خطأ قديم — نفس نمط
      // `EditIdentityState`.
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    view,
    submission,
    request,
    user,
    nationalId,
    frontImage,
    selfieImage,
    errorMessage,
  ];
}
