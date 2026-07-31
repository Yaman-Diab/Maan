// -------------------------
// Auth User
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/session/account_status.dart';

/// المستخدم المصادَق عليه.
///
/// الحقول مشتقّة من استجابة `/api/profile` الحقيقية بـ`collection.md` —
/// أول توثيق فعلي لشكل المستخدم، وقبله كان `Map<String, dynamic>` مبهم.
///
/// كل الحقول اختيارية عدا [id] لأن الاستجابة الموثّقة بترجّع `null`
/// لكتير منها (`phone`, `email_verified_at`, `fcm_token`, `expires_at`).
final class AuthUser extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? nationalId;

  /// بصيغة `YYYY-MM-DD` بالاستجابة — لاحظ إنها **تختلف** عن صيغة
  /// الإرسال بالتسجيل (`YYYY/M/D`).
  final DateTime? birthDate;

  final DateTime? emailVerifiedAt;
  final bool privacyPolicyAccepted;
  final bool termsOfServiceAccepted;
  final String? fcmToken;

  final AccountStatus accountStatus;

  /// عدد محاولات التوثيق المستهلكة — الحد الأقصى 3.
  final int verificationAttempts;

  /// نهاية مهلة تصحيح التوثيق (14 يوم).
  final DateTime? expiresAt;

  const AuthUser({
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

  String get fullName => '$firstName $lastName'.trim();

  bool get isEmailVerified => emailVerifiedAt != null;

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phone,
    nationalId,
    birthDate,
    emailVerifiedAt,
    privacyPolicyAccepted,
    termsOfServiceAccepted,
    fcmToken,
    accountStatus,
    verificationAttempts,
    expiresAt,
  ];
}
