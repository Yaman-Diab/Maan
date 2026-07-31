// -------------------------
// API Envelope
// -------------------------

import 'api_response_keys.dart';

/// كشف الفشل المخبّأ داخل استجابة ناجحة.
///
/// الـ backend بيرجّع **HTTP 200 حتى عند الفشل**، والحالة الحقيقية
/// بالجسم. أمثلة موثّقة بـ`collection.md`:
///
/// ```json
/// {"status":0,"message":"Route not found.","errors":["route_not_found"]}
/// {"status":0,"message":"Location not allowed. You must be inside the municipality."}
/// {"success":false,"message":"Validation Error.","errors":{"status.0":[...]}}
/// ```
///
/// بلا هذا الفحص كان الفشل بيمرّ كنجاح: المواطن بينضاف للطابور بذهنه
/// وهو مرفوض، والشكوى بتنحفظ بذهنه وهي فشلت.
class ApiEnvelope {
  ApiEnvelope._();

  /// هل الجسم بيعلن فشلاً رغم أن رمز HTTP ناجح؟
  ///
  /// متحفّظ عمداً: بيعتبرها فشلاً فقط لما تكون الإشارة **صريحة**
  /// (`status` رقمه صفر، أو `success` قيمته `false`). أي شي غير هيك
  /// بيمرّ كنجاح، حتى ما نكسر endpoint بيرجّع حقل اسمه `status` بمعنى
  /// تاني — مثل خدمة حالتها `"active"`.
  static bool indicatesFailure(dynamic data) {
    if (data is! Map) return false;

    if (_isExplicitFalse(data[ApiResponseKeys.success])) return true;
    if (_isNumericZero(data[ApiResponseKeys.status])) return true;

    return false;
  }

  static bool _isExplicitFalse(dynamic value) => value is bool && !value;

  /// `0` أو `"0"` فقط. `"active"` أو `null` أو غياب المفتاح مش فشل.
  static bool _isNumericZero(dynamic value) {
    if (value is bool) return false;
    if (value is num) return value == 0;
    if (value is String) return num.tryParse(value) == 0;

    return false;
  }
}
