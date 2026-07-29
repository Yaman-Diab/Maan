// -------------------------
// Login Cubit
// -------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/result/result.dart';
import '../../../domain/usecases/login_usecase.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginCubit(this._loginUseCase) : super(const LoginState());

  void emailChanged(String value) {
    emit(state.copyWith(email: value.trim()));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value));
  }

  void termsToggled(bool value) {
    emit(state.copyWith(isTermsAccepted: value));
  }

  /// [isFormValid] بيجي من `Form.validate()` بالصفحة، لأن قواعد التحقق
  /// من الحقول مربوطة بالـ widgets وما بينفع الـ Cubit يشغّلها.
  Future<void> submit({required bool Function() isFormValid}) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(hasTriedSubmit: true));

    if (!isFormValid()) return;

    emit(state.copyWith(status: LoginStatus.submitting));

    final result = await _loginUseCase(
      LoginParams(email: state.email, password: state.password),
    );

    switch (result) {
      case Ok():
        emit(state.copyWith(status: LoginStatus.success));

      case Err(:final failure):
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
