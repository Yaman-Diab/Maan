// -------------------------
// Login Use Case
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';
import '../repositories/session_repository.dart';

final class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// تسجيل الدخول ثم حفظ الجلسة كخطوة واحدة.
///
/// خطوة الحفظ كانت قبل الهجرة عايشة جوّا `_LoginPageState._submit`،
/// يعني منطق تنسيق داخل الواجهة. صارت هون فبتنطبق على أي واجهة
/// بتسجّل دخول وبتصير قابلة للاختبار لحالها.
class LoginUseCase implements UseCase<AuthSession, LoginParams> {
  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;

  const LoginUseCase(this._authRepository, this._sessionRepository);

  @override
  Future<Result<AuthSession>> call(LoginParams params) async {
    final result = await _authRepository.login(
      email: params.email,
      password: params.password,
    );

    if (result case Ok(:final value)) {
      await _sessionRepository.persistSession(value);
    }

    return result;
  }
}
