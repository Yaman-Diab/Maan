import 'package:flutter_test/flutter_test.dart';
import 'package:maan/features/auth/domain/entities/password_checks.dart';

/// حارس ضد ارتداد السلوك بعد ربط `PasswordChecks` بـ`PasswordPolicy`
/// المشتركة مع `AppValidators`.
void main() {
  test('empty بترجع كل القواعد false', () {
    final checks = PasswordChecks.empty();

    expect(checks.hasMinLength, isFalse);
    expect(checks.hasNumber, isFalse);
    expect(checks.hasSpecialCharacter, isFalse);
    expect(checks.hasUpperAndLowerCase, isFalse);
    expect(checks.isStrong, isFalse);
  });

  test('كلمة مرور مستوفية كل الشروط', () {
    final checks = PasswordChecks.fromPassword('Abcdefg1!');

    expect(checks.hasMinLength, isTrue);
    expect(checks.hasNumber, isTrue);
    expect(checks.hasSpecialCharacter, isTrue);
    expect(checks.hasUpperAndLowerCase, isTrue);
    expect(checks.isStrong, isTrue);
  });

  group('hasUpperAndLowerCase — قاعدة مدموجة تحتاج الاثنين معاً', () {
    test('حرف كبير بلا صغير بتضل false', () {
      final checks = PasswordChecks.fromPassword('ABCDEFG1!');
      expect(checks.hasUpperAndLowerCase, isFalse);
    });

    test('حرف صغير بلا كبير بتضل false', () {
      final checks = PasswordChecks.fromPassword('abcdefg1!');
      expect(checks.hasUpperAndLowerCase, isFalse);
    });
  });

  test('isStrong بيحتاج كل القواعد الأربعة معاً', () {
    // ناقصة الرمز الخاص فقط.
    final checks = PasswordChecks.fromPassword('Abcdefg1');

    expect(checks.hasMinLength, isTrue);
    expect(checks.hasNumber, isTrue);
    expect(checks.hasUpperAndLowerCase, isTrue);
    expect(checks.hasSpecialCharacter, isFalse);
    expect(checks.isStrong, isFalse);
  });

  test('المساواة بين قيمتين بنفس القواعد', () {
    final a = PasswordChecks.fromPassword('Abcdefg1!');
    final b = PasswordChecks.fromPassword('Zyxwvut9@');

    expect(a, b);
  });
}
