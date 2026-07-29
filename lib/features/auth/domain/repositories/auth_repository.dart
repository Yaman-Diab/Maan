// -------------------------
// Auth Repository (Contract)
// -------------------------

import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../entities/birth_date.dart';

/// عقد المصادقة كما تراه طبقة الـ domain.
///
/// بيرجّع [Result] بدل ما يرمي استثناءات، والتنفيذ الفعلي
/// (`AuthRepositoryImpl`) هو اللي بيعرف Dio والـ endpoints.
abstract class AuthRepository {
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });

  /// بينشئ الحساب. الـ backend بيبعت رمز تحقق للبريد بعدها،
  /// فما في جلسة بترجع من هون.
  Future<Result<void>> register({
    required String firstName,
    required String lastName,
    required BirthDate birthDate,
    required String email,
    required String password,
  });

  Future<Result<void>> verifyOtp({
    required String email,
    required String code,
  });

  Future<Result<void>> resendOtp({required String email});

  /// بيطلب رمز إعادة تعيين كلمة المرور.
  Future<Result<void>> requestPasswordReset({required String email});

  Future<Result<void>> resetPassword({
    required String email,
    required String code,
    required String password,
  });
}
