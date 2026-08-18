import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/format/amount_formatter.dart';

void main() {
  group('AmountFormatter.format', () {
    test('بيضيف فواصل آلاف', () {
      expect(AmountFormatter.format(650000), '650,000');
      expect(AmountFormatter.format(1000000), '1,000,000');
      expect(AmountFormatter.format(350000), '350,000');
    });

    test('أرقام صغيرة بلا فواصل', () {
      expect(AmountFormatter.format(0), '0');
      expect(AmountFormatter.format(999), '999');
    });

    test('الكسور بتنعرض لو موجودة', () {
      expect(AmountFormatter.format(1234.5), '1,234.5');
    });

    test('أرقام لاتينية دائماً — القرار موثّق بـAmountFormatter (اتساق مع '
        'باقي أرقام التطبيق)', () {
      final formatted = AmountFormatter.format(650000);

      // ما في أرقام هندية (٠-٩) بالناتج مهما كانت لغة التطبيق.
      expect(RegExp(r'^[0-9,]+$').hasMatch(formatted), isTrue);
    });
  });
}
