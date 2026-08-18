import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/network/api_error_messages.dart';
import 'package:maan/core/network/api_status_codes.dart';

void main() {
  group('ApiErrorMessages — 409 Conflict', () {
    // ⚠️ باگ حقيقي انصلح: 409 ما كان إله case بـ`_messageFromStatusCode`،
    // فكان بيسقط على `fallbackMessage` — رسالة الباك اند الخام، اللي
    // عقد التصويت المؤكّد بيثبت إنها إنجليزي دائماً (مثلاً "You have
    // already voted on this complaint") بغض النظر عن لغة التطبيق.
    // `.tr()` بترجّع المفتاح نفسه بلا `EasyLocalization` مهيّأة، فهالاختبار
    // مستقل عن اللغة (نفس نمط بقية اختبارات الرسائل بالمشروع).
    test('بيرجع رسالة مترجَمة عامة لا رسالة الباك اند الخام', () {
      final message = ApiErrorMessages.getUserFriendlyMessage(
        statusCode: ApiStatusCodes.conflict,
        fallbackMessage: 'You have already voted on this complaint',
      );

      expect(message, 'error_conflict');
    });

    test('بلا fallbackMessage كمان بترجع نفس المفتاح', () {
      final message = ApiErrorMessages.getUserFriendlyMessage(
        statusCode: ApiStatusCodes.conflict,
      );

      expect(message, 'error_conflict');
    });
  });
}
