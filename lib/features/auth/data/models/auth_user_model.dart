// -------------------------
// Auth User Model
// -------------------------

import '../../../../core/session/account_status.dart';
import '../../domain/entities/auth_user.dart';

/// قراءة حقول المستخدم كما وصلت فعلياً بـ`POST /api/auth/login` —
/// أول استجابة حقيقية موثّقة، بديلاً عن `Map<String, dynamic>` مبهم.
///
/// نفس مجموعة الحقول متوقّعة لاحقاً من `/api/profile` تحت `data.user`،
/// فهذا الملف مكانه الصح لإعادة الاستخدام يوم تُبنى تلك الميزة.
class AuthUserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? nationalId;
  final DateTime? birthDate;
  final DateTime? emailVerifiedAt;
  final bool privacyPolicyAccepted;
  final bool termsOfServiceAccepted;
  final String? fcmToken;
  final AccountStatus accountStatus;
  final int verificationAttempts;
  final DateTime? expiresAt;

  const AuthUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.accountStatus,
    this.phone,
    this.nationalId,
    this.birthDate,
    this.emailVerifiedAt,
    this.privacyPolicyAccepted = false,
    this.termsOfServiceAccepted = false,
    this.fcmToken,
    this.verificationAttempts = 0,
    this.expiresAt,
  });

  factory AuthUserModel.fromMap(Map<String, dynamic> json) {
    final id = json['id'];

    if (id is! int) {
      throw const FormatException('User data is missing an id.');
    }

    final firstName = json['first_name'] as String?;
    final lastName = json['last_name'] as String?;
    final email = json['email'] as String?;

    if (firstName == null || lastName == null || email == null) {
      throw const FormatException('User data is missing required fields.');
    }

    return AuthUserModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: json['phone'] as String?,
      nationalId: json['national_id'] as String?,
      birthDate: _tryParseDate(json['birth_date']),
      emailVerifiedAt: _tryParseDate(json['email_verified_at']),
      privacyPolicyAccepted: _asBool(json['privacy_policy_accepted']),
      termsOfServiceAccepted: _asBool(json['terms_of_service_accepted']),
      fcmToken: json['fcm_token'] as String?,
      accountStatus: AccountStatus.fromApi(json['account_status'] as String?),
      verificationAttempts: (json['verification_attempts'] as num?)?.toInt() ?? 0,
      expiresAt: _tryParseDate(json['expires_at']),
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      accountStatus: accountStatus,
      phone: phone,
      nationalId: nationalId,
      birthDate: birthDate,
      emailVerifiedAt: emailVerifiedAt,
      privacyPolicyAccepted: privacyPolicyAccepted,
      termsOfServiceAccepted: termsOfServiceAccepted,
      fcmToken: fcmToken,
      verificationAttempts: verificationAttempts,
      expiresAt: expiresAt,
    );
  }

  /// `0`/`1` من الـ backend، لا `true`/`false`.
  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    return false;
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;

    return DateTime.tryParse(value);
  }
}
