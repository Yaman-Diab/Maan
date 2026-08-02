// -------------------------
// Verification Repository
// -------------------------

import '../../../../core/media/picked_image.dart';
import '../../../../core/result/result.dart';
import '../entities/verification_request.dart';

abstract class VerificationRepository {
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
}
