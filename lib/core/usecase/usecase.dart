// -------------------------
// Use Case
// -------------------------

import '../result/result.dart';

/// العقد المشترك لكل الـ use cases.
///
/// الـ use case بينسّق خطوة عمل واحدة فوق الـ repositories، وبيبقى نقي:
/// بلا Flutter وبلا Dio وبلا معرفة بالواجهة.
///
/// [T] نوع القيمة عند النجاح، و[P] نوع المدخلات (استخدم [NoParams] لو ما في).
///
/// ```dart
/// final result = await loginUseCase(LoginParams(email: ..., password: ...));
/// ```
abstract class UseCase<T, P> {
  Future<Result<T>> call(P params);
}

/// للـ use cases اللي ما بتاخد مدخلات.
final class NoParams {
  const NoParams();
}
