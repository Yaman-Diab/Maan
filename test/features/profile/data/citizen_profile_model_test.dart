import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/features/profile/data/models/citizen_profile_model.dart';

/// حقول المستخدم كما بيرجّعها الباك اند — نفس الشكل الموثّق باستجابة
/// الدخول الحقيقية، لأن `/api/profile` بيرجّع نفس الكائن.
Map<String, dynamic> _userFields() {
  return {
    'id': 7,
    'first_name': 'Yaman',
    'last_name': 'Diab',
    'email': 'yamandiab7@gmail.com',
    'phone': null,
    'national_id': '123456789012',
    'birth_date': '1998-10-12',
    'email_verified_at': '2026-07-30T10:00:00.000000Z',
    'privacy_policy_accepted': 1,
    'terms_of_service_accepted': 1,
    'fcm_token': null,
    'account_status': 'verified',
    'verification_attempts': 0,
    'expires_at': null,
  };
}

void main() {
  group('مستويات التعشيش الثلاثة كلها بتنقرأ', () {
    test('الجسم مسطّح بالجذر', () {
      final model = CitizenProfileModel.fromMap(_userFields());

      expect(model.user.id, 7);
      expect(model.user.accountStatus, AccountStatus.verified);
    });

    test('الجسم تحت data', () {
      final model = CitizenProfileModel.fromMap({
        'status': 1,
        'message': 'ok',
        'data': _userFields(),
      });

      expect(model.user.email, 'yamandiab7@gmail.com');
    });

    test('الجسم تحت data.user', () {
      final model = CitizenProfileModel.fromMap({
        'status': 1,
        'data': {'user': _userFields()},
      });

      expect(model.user.firstName, 'Yaman');
    });
  });

  group('المؤشرات — لسه ما إلها عقد', () {
    test('غيابها ما بيرمي، بترجع null', () {
      final model = CitizenProfileModel.fromMap(_userFields());

      expect(model.stats.citizenshipIndex, isNull);
      expect(model.stats.authenticationIndex, isNull);
      expect(model.stats.volunteeringCount, isNull);
      expect(model.stats.contributionsCount, isNull);
      expect(model.stats.licensesCount, isNull);
      expect(model.stats.isEmpty, isTrue);
    });

    test('بتنقرأ لو وصلت جنب المستخدم', () {
      final model = CitizenProfileModel.fromMap({
        'data': {
          'user': _userFields(),
          'citizenship_index': 75,
          'authentication_index': 40,
          'volunteering_count': 15,
          'contributions_count': 7,
          'licenses_count': 5,
        },
      });

      expect(model.stats.citizenshipIndex, 75);
      expect(model.stats.authenticationIndex, 40);
      expect(model.stats.volunteeringCount, 15);
      expect(model.stats.contributionsCount, 7);
      expect(model.stats.licensesCount, 5);
    });

    test('بتنقرأ لو وصلت جوّا المستخدم', () {
      final model = CitizenProfileModel.fromMap(
        _userFields()..['citizenship_index'] = 60,
      );

      expect(model.stats.citizenshipIndex, 60);
    });

    test('رقم كنص بينقرأ كمان — Laravel بيرجّع الأعداد كنصوص أحياناً', () {
      final model = CitizenProfileModel.fromMap(
        _userFields()..['volunteering_count'] = '15',
      );

      expect(model.stats.volunteeringCount, 15);
    });

    test('نسبة خارج المدى بتتقصّ بدل ما تكسر شريط التقدّم', () {
      final model = CitizenProfileModel.fromMap(
        _userFields()
          ..['citizenship_index'] = 140
          ..['authentication_index'] = -20,
      );

      expect(model.stats.citizenshipIndex, 100);
      expect(model.stats.authenticationIndex, 0);
    });

    test('العدّادات ما بتتقصّ — مالها سقف', () {
      final model = CitizenProfileModel.fromMap(
        _userFields()..['volunteering_count'] = 250,
      );

      expect(model.stats.volunteeringCount, 250);
    });
  });

  group('الحقول الناقصة', () {
    test('بلا id بترمي FormatException', () {
      expect(
        () => CitizenProfileModel.fromMap(_userFields()..remove('id')),
        throwsFormatException,
      );
    });
  });

  test('toEntity بتنقل الهوية والمؤشرات سوا', () {
    final entity = CitizenProfileModel.fromMap({
      'data': {'user': _userFields(), 'licenses_count': 5},
    }).toEntity();

    expect(entity.user.nationalId, '123456789012');
    expect(entity.user.birthDate, DateTime.parse('1998-10-12'));
    expect(entity.stats.licensesCount, 5);
  });
}
