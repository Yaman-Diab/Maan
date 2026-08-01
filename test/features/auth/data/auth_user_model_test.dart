import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/features/auth/data/models/auth_user_model.dart';

/// نسخة طبق الأصل عن `data` باستجابة `/api/auth/login` الحقيقية.
Map<String, dynamic> _realUserData() {
  return {
    'id': 1,
    'first_name': 'Yaman',
    'last_name': 'Diab',
    'email': 'yamandiab7@gmail.com',
    'phone': null,
    'national_id': null,
    'birth_date': '2003-01-01',
    'email_verified_at': null,
    'privacy_policy_accepted': 0,
    'terms_of_service_accepted': 0,
    'fcm_token': null,
    'account_status': 'visitor',
    'verification_attempts': 0,
    'expires_at': null,
    'created_at': '2026-08-01T04:53:26.000000Z',
    'updated_at': '2026-08-01T04:53:26.000000Z',
    'deleted_at': null,
    'token': 'the-token',
    'token_type': 'Bearer',
  };
}

void main() {
  group('fromMap — الاستجابة الحقيقية', () {
    test('بتقرأ الحقول الأساسية', () {
      final model = AuthUserModel.fromMap(_realUserData());

      expect(model.id, 1);
      expect(model.firstName, 'Yaman');
      expect(model.lastName, 'Diab');
      expect(model.email, 'yamandiab7@gmail.com');
      expect(model.accountStatus, AccountStatus.visitor);
    });

    test('بتتجاهل الحقول الزائدة (token, token_type, created_at...)', () {
      // ما لازم ترمي لمجرد وجود مفاتيح إضافية بالخريطة.
      expect(() => AuthUserModel.fromMap(_realUserData()), returnsNormally);
    });

    test('0/1 بتتحوّل لـ bool', () {
      final data = _realUserData()
        ..['privacy_policy_accepted'] = 1
        ..['terms_of_service_accepted'] = 0;

      final model = AuthUserModel.fromMap(data);

      expect(model.privacyPolicyAccepted, isTrue);
      expect(model.termsOfServiceAccepted, isFalse);
    });

    test('null بالحقول الاختيارية بتضل null', () {
      final model = AuthUserModel.fromMap(_realUserData());

      expect(model.phone, isNull);
      expect(model.nationalId, isNull);
      expect(model.emailVerifiedAt, isNull);
      expect(model.fcmToken, isNull);
      expect(model.expiresAt, isNull);
    });

    test('birth_date بصيغة ISO بتتحوّل لـ DateTime', () {
      final model = AuthUserModel.fromMap(_realUserData());

      expect(model.birthDate, DateTime.parse('2003-01-01'));
    });

    test('account_status غير معروفة بترجع unknown بدل ما ترمي', () {
      final data = _realUserData()..['account_status'] = 'something_new';

      final model = AuthUserModel.fromMap(data);

      expect(model.accountStatus, AccountStatus.unknown);
    });
  });

  group('fromMap — الحقول الناقصة بترمي', () {
    test('بلا id', () {
      final data = _realUserData()..remove('id');

      expect(() => AuthUserModel.fromMap(data), throwsFormatException);
    });

    test('بلا first_name', () {
      final data = _realUserData()..remove('first_name');

      expect(() => AuthUserModel.fromMap(data), throwsFormatException);
    });

    test('بلا email', () {
      final data = _realUserData()..remove('email');

      expect(() => AuthUserModel.fromMap(data), throwsFormatException);
    });
  });

  test('toEntity بتحافظ على كل القيم', () {
    final entity = AuthUserModel.fromMap(_realUserData()).toEntity();

    expect(entity.id, 1);
    expect(entity.email, 'yamandiab7@gmail.com');
    expect(entity.accountStatus, AccountStatus.visitor);
  });
}
