// -------------------------
// Forgot Password Cubit
// -------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/result/result.dart';
import '../../../domain/usecases/forget_password_usecase.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgetPasswordUseCase _forgetPasswordUseCase;

  ForgotPasswordCubit(this._forgetPasswordUseCase)
    : super(const ForgotPasswordState());

  void emailChanged(String value) {
    emit(state.copyWith(email: value.trim()));
  }

  Future<void> submit({required bool Function() isFormValid}) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(hasTriedSubmit: true));

    if (!isFormValid()) return;

    emit(state.copyWith(status: ForgotPasswordStatus.submitting));

    final result = await _forgetPasswordUseCase(
      ForgetPasswordParams(email: state.email),
    );

    switch (result) {
      case Ok():
        emit(state.copyWith(status: ForgotPasswordStatus.success));

      case Err(:final failure):
        emit(
          state.copyWith(
            status: ForgotPasswordStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
