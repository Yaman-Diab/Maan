// -------------------------
// Auth Session
// -------------------------

import 'package:equatable/equatable.dart';

/// جلسة مستخدم مصادَق عليه: التوكنات وبيانات المستخدم.
///
/// كيان domain نقي — بلا Dio وبلا Flutter وبلا مفاتيح JSON.
/// تحويل استجابة الشبكة لهذا الكيان مسؤولية `LoginResponseModel`.
final class AuthSession extends Equatable {
  final String accessToken;
  final String refreshToken;

  /// بيانات المستخدم كما رجّعها الـ backend.
  ///
  /// لسه `Map` لأن شكل المستخدم غير موثّق من طرف الـ backend، وما في
  /// أي كود بيقرأه حالياً (بس بينحفظ بالتخزين الآمن). أول ما يتحدّد
  /// عقد `/users/me/` بينحوّل لكيان `AuthUser` مكتوب الأنواع.
  final Map<String, dynamic>? user;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  bool get hasUser => user != null && user!.isNotEmpty;

  @override
  List<Object?> get props => [accessToken, refreshToken, user];

  @override
  String toString() =>
      'AuthSession(accessToken: [REDACTED], refreshToken: [REDACTED], user: $user)';
}
