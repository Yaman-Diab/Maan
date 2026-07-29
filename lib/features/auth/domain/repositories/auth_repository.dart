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
    required String nationalId,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  /// تأكيد رمز التحقق. الـ backend بيعرف صاحب الرمز من الجلسة،
  /// فما بيلزمه بريد.
  Future<Result<void>> checkCode({required String code});

  /// إعادة إرسال رسالة التحقق.
  Future<Result<void>> resendVerification();

  /// بيطلب رمز إعادة تعيين كلمة المرور على البريد.
  Future<Result<void>> forgetPassword({required String email});

  Future<Result<void>> resetPassword({
    required String code,
    required String password,
    required String passwordConfirmation,
  });
}
