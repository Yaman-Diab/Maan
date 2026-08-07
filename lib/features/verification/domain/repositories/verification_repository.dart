// -------------------------
// Verification Repository
// -------------------------

import '../../../../core/media/picked_image.dart';
import '../../../../core/result/result.dart';
import '../entities/verification_request.dart';

abstract class VerificationRepository {
  /// آخر طلب توثيق للمستخدم الحالي، أو `null` لو ما قدّم ولا طلب.
  ///
  /// هي اللي بتحدّد شو تعرض شاشة التوثيق أول ما تُفتح: بلا طلب →
  /// النموذج، `pending` → قيد المراجعة، `rejected` → الرفض،
  /// `approved` → الاعتماد. «آخر» = الأحدث بـ`createdAt` لأن المستخدم
  /// ممكن يكون قدّم أكتر من طلب عبر الوقت (رفض ثم إعادة إرسال)، والشاشة
  /// بتهمّها الحالة الحالية لا التاريخ.
  Future<Result<VerificationRequest?>> latestRequest();

  /// تقديم طلب توثيق الهوية.
  ///
  /// [images] لازم يكون **بالضبط عنصرين** — قاعدة `size:2` مؤكّدة من
  /// رسالة خطأ الباك اند، مش حد أدنى. عام [PickedImage] لا خاص بهالميزة:
  /// نفس النوع اللي بيرجّعه `ImagePickerService` لصورة البروفايل.
  /// **ملاحظة لمن يبني شاشة الاختيار**: قصّ صورة البروفايل الدائري
  /// (`pickAvatar`) مش مناسب هون؛ هدول صور وثيقة (هوية/سيلفي) بتحتاج
  /// مسار اختيار بلا قصّ دائري.
  Future<Result<VerificationRequest>> submit({
    required String nationalId,
    required List<PickedImage> images,
  });

  /// تصحيح رقم وطني بطلب توثيق **قائم لسه قيد المراجعة** — بلا إعادة
  /// رفع الصور. [requestId] هو `VerificationRequest.id` تبع الطلب
  /// الأصلي، مش أي مُعرّف تاني.
  ///
  /// ⚠️ الصور مش جزء من هالعملية — العقد المؤكّد بس `id` + `national_id`.
  /// لو المستخدم بده يصحّح صورة غلط، ما في مسار مؤكّد لهيك لسه.
  Future<Result<VerificationRequest>> update({
    required int requestId,
    required String nationalId,
  });
}
