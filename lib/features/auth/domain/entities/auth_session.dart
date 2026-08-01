// -------------------------
// Auth Session
// -------------------------

import 'package:equatable/equatable.dart';

import 'auth_user.dart';

/// جلسة مستخدم مصادَق عليه: التوكن وبيانات المستخدم.
///
/// كيان domain نقي — بلا Dio وبلا Flutter وبلا مفاتيح JSON.
/// تحويل استجابة الشبكة لهذا الكيان مسؤولية `LoginResponseModel`.
///
/// توكن واحد لا زوج access/refresh: الـ backend بيستخدم JWT من طراز
/// `tymon/jwt-auth` (تأكّدنا من بنية التوكن الفعلية)، ونفس التوكن
/// بينبعت من جديد على `/api/auth/refresh` لتجديد صلاحيته — ما في
/// refresh token منفصل يُخزَّن.
final class AuthSession extends Equatable {
  final String accessToken;
  final AuthUser user;

  const AuthSession({required this.accessToken, required this.user});

  @override
  List<Object?> get props => [accessToken, user];

  @override
  String toString() => 'AuthSession(accessToken: [REDACTED], user: $user)';
}
