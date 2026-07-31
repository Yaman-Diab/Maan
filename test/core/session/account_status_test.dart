import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/session/account_status.dart';

void main() {
  group('fromApi', () {
    test('القيمة المؤكّدة من collection.md', () {
      // `"account_status":"verified"` باستجابة /api/profile الحقيقية.
      expect(AccountStatus.fromApi('verified'), AccountStatus.verified);
    });

    test('باقي القيم المتوقّعة', () {
      expect(AccountStatus.fromApi('visitor'), AccountStatus.visitor);
      expect(AccountStatus.fromApi('blocked'), AccountStatus.blocked);
      expect(
        AccountStatus.fromApi('pending_verification'),
        AccountStatus.pendingVerification,
      );
    });

    test('قيمة غير معروفة بترجع unknown بدل ما ترمي', () {
      // الباك اند ممكن يضيف حالة جديدة؛ ما بدنا التطبيق ينهار.
      expect(AccountStatus.fromApi('suspended'), AccountStatus.unknown);
      expect(AccountStatus.fromApi(''), AccountStatus.unknown);
      expect(AccountStatus.fromApi(null), AccountStatus.unknown);
    });
  });

  group('الصلاحيات', () {
    test('الموثّق وحده بيوصل لخدمات البلدية', () {
      expect(AccountStatus.verified.canUseMunicipalityServices, isTrue);

      for (final status in [
        AccountStatus.visitor,
        AccountStatus.pendingVerification,
        AccountStatus.blocked,
        AccountStatus.unknown,
      ]) {
        expect(
          status.canUseMunicipalityServices,
          isFalse,
          reason: '$status ما لازم يوصل للخدمات',
        );
      }
    });

    test('الحالة المجهولة بتنعامل كأقل صلاحية', () {
      // أأمن من افتراض إن المستخدم موثّق.
      expect(AccountStatus.unknown.canUseMunicipalityServices, isFalse);
    });

    test('isBlocked بتميّز المحظور وحده', () {
      expect(AccountStatus.blocked.isBlocked, isTrue);
      expect(AccountStatus.verified.isBlocked, isFalse);
      expect(AccountStatus.unknown.isBlocked, isFalse);
    });
  });

  test('كل قيمة إلها wireValue فريد عدا unknown', () {
    final wireValues = AccountStatus.values
        .where((s) => s != AccountStatus.unknown)
        .map((s) => s.wireValue)
        .toList();

    expect(wireValues.toSet().length, wireValues.length);
    expect(wireValues, isNot(contains('')));
  });
}
