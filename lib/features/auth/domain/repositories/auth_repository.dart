// -------------------------
// Auth Repository (Contract)
// -------------------------

import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';

/// عقد المصادقة كما تراه طبقة الـ domain.
///
/// بيرجّع [Result] بدل ما يرمي استثناءات، والتنفيذ الفعلي
/// (`AuthRepositoryImpl`) هو اللي بيعرف Dio والـ endpoints.
abstract class AuthRepository {
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });
}
