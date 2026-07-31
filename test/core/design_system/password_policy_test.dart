import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/password_policy.dart';

void main() {
  group('hasMinLength', () {
    test('8 أحرف بالضبط مقبولة', () {
      expect(PasswordPolicy.hasMinLength('12345678'), isTrue);
    });

    test('أقل من 8 مرفوضة', () {
      expect(PasswordPolicy.hasMinLength('1234567'), isFalse);
    });
  });

  test('hasDigit بتكتشف أي رقم', () {
    expect(PasswordPolicy.hasDigit('abc1'), isTrue);
    expect(PasswordPolicy.hasDigit('abc'), isFalse);
  });

  test('hasUppercase و hasLowercase مستقلتان', () {
    expect(PasswordPolicy.hasUppercase('ABC'), isTrue);
    expect(PasswordPolicy.hasUppercase('abc'), isFalse);
    expect(PasswordPolicy.hasLowercase('abc'), isTrue);
    expect(PasswordPolicy.hasLowercase('ABC'), isFalse);
  });

  group('hasSpecialCharacter', () {
    test('كل رموز الصنف المدعومة', () {
      const symbols = r'!@#$%^&*(),.?":{}|<>_-\/[]=+';

      for (final symbol in symbols.split('')) {
        expect(
          PasswordPolicy.hasSpecialCharacter('abc$symbol'),
          isTrue,
          reason: 'الرمز "$symbol" لازم يُحتسب',
        );
      }
    });

    test('بلا أي رمز خاص مرفوضة', () {
      expect(PasswordPolicy.hasSpecialCharacter('abc123'), isFalse);
    });
  });
}
