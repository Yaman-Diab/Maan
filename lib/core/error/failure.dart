// -------------------------
// Failure
// -------------------------

import 'package:equatable/equatable.dart';

/// تمثيل الفشل داخل طبقتَي domain و presentation.
///
/// الـ domain ما بتعرف شي عن Dio ولا عن [ApiException]، فالـ data layer
/// هي اللي بتحوّل الاستثناء لـ [Failure] عبر `FailureMapper`.
///
/// [message] جاهزة للعرض للمستخدم مباشرةً — مصدرها `ApiException.userMessage`
/// اللي بيبنيها `ApiErrorMessages.getUserFriendlyMessage`.
sealed class Failure extends Equatable {
  final String message;

  /// كود الخطأ القادم من الـ backend مثل `otp_expired`. مفيد للتمييز
  /// بين حالات فرعية بدون مقارنة نصوص الرسائل.
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// انقطاع اتصال أو انتهاء مهلة — ما وصلنا للسيرفر أصلاً.
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// بيانات دخول خاطئة، حساب غير مفعّل، أو توكن غير صالح (401/403).
final class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// خطأ تحقق من المدخلات (400)، مع أخطاء الحقول لو رجّعها الـ backend.
final class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure(super.message, {super.code, this.fieldErrors});

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// رمز تحقق خاطئ أو منتهي أو تجاوز عدد المحاولات.
final class OtpFailure extends Failure {
  const OtpFailure(super.message, {super.code});
}

/// تجاوز الحد المسموح من الطلبات (429) — المطلوب انتظار قبل إعادة المحاولة.
final class RateLimitFailure extends Failure {
  const RateLimitFailure(super.message, {super.code});
}

/// خطأ من طرف السيرفر (5xx).
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// أي شي ما انطبق عليه تصنيف أوضح.
final class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
