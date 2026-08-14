import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/session/account_status.dart';

void main() {
  group('fromApi', () {
    // ✅ الثلاث قيم مؤكّدة بالكامل من enum الباك اند الحقيقي
    // (`App\Enums\AccountStatus`).
    test('القيم الثلاث المؤكّدة من enum الباك اند', () {
      expect(AccountStatus.fromApi('verified'), AccountStatus.verified);
      expect(AccountStatus.fromApi('visitor'), AccountStatus.visitor);
      expect(AccountStatus.fromApi('closed'), AccountStatus.closed);
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
        AccountStatus.closed,
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

    test('isClosed بتميّز المقفول وحده', () {
      expect(AccountStatus.closed.isClosed, isTrue);
      expect(AccountStatus.verified.isClosed, isFalse);
      expect(AccountStatus.unknown.isClosed, isFalse);
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
