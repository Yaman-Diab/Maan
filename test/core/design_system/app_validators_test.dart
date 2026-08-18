import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_validators.dart';

/// حارس ضد ارتداد السلوك بعد نقل قواعد كلمة المرور لـ`PasswordPolicy`.
///
/// كل حالة هون كانت تمرّ بنفس النتيجة قبل استخراج `PasswordPolicy` —
/// الهدف إثبات إن الاستخراج ما غيّر أي رسالة ولا أي ترتيب فحص.
void main() {
  group('emailValidator', () {
    test('فاضي مطلوب', () {
      expect(AppValidators.emailValidator(''), 'email_required');
      expect(AppValidators.emailValidator(null), 'email_required');
    });

    test('صيغة غير صحيحة', () {
      expect(AppValidators.emailValidator('not-an-email'), 'email_invalid');
    });

    test('صيغة صحيحة بترجع null', () {
      expect(AppValidators.emailValidator('user@example.com'), isNull);
    });
  });

  group('passwordValidator — ترتيب الفحص محفوظ حرفياً', () {
    test('فاضية مطلوبة', () {
      expect(AppValidators.passwordValidator(''), 'password_required');
    });

    test('أقصر من 8 أحرف', () {
      expect(AppValidators.passwordValidator('Ab1!'), 'password_too_short');
    });

    test('بلا رقم', () {
      expect(
        AppValidators.passwordValidator('Abcdefgh!'),
        'password_needs_digit',
      );
    });

    test('بلا حرف كبير', () {
      expect(
        AppValidators.passwordValidator('abcdefg1!'),
        'password_needs_uppercase',
      );
    });

    test('بلا حرف صغير', () {
      expect(
        AppValidators.passwordValidator('ABCDEFG1!'),
        'password_needs_lowercase',
      );
    });

    test('بلا رمز خاص', () {
      expect(
        AppValidators.passwordValidator('Abcdefg1'),
        'password_needs_special_char',
      );
    });

    test('مستوفية كل الشروط بترجع null', () {
      expect(AppValidators.passwordValidator('Abcdefg1!'), isNull);
    });
  });

  group('loginPasswordValidator — بلا سياسة قوة', () {
    test('فاضية مطلوبة', () {
      expect(AppValidators.loginPasswordValidator(''), 'password_required');
      expect(AppValidators.loginPasswordValidator(null), 'password_required');
    });

    test('كلمة مرور ما بتحقق سياسة القوة الحالية بترجع null', () {
      // حساب قديم بكلمة مرور صحيحة بس بلا رمز خاص — لازم يقدر يدخل.
      expect(AppValidators.loginPasswordValidator('short'), isNull);
      expect(AppValidators.loginPasswordValidator('alllowercase'), isNull);
    });
  });

  group('confirmPasswordValidator', () {
    test('فاضي مطلوب', () {
      expect(
        AppValidators.confirmPasswordValidator('', 'Abcdefg1!'),
        'confirm_password_required',
      );
    });

    test('غير مطابق', () {
      expect(
        AppValidators.confirmPasswordValidator('different', 'Abcdefg1!'),
        'passwords_do_not_match',
      );
    });

    test('مطابق بيرجع null', () {
      expect(
        AppValidators.confirmPasswordValidator('Abcdefg1!', 'Abcdefg1!'),
        isNull,
      );
    });
  });
}
