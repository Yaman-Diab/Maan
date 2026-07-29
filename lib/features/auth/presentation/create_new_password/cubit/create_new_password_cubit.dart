// -------------------------
// Create New Password Cubit
// -------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/result/result.dart';
import '../../../domain/usecases/reset_password_usecase.dart';
import 'create_new_password_state.dart';

class CreateNewPasswordCubit extends Cubit<CreateNewPasswordState> {
  final ResetPasswordUseCase _resetPasswordUseCase;

  CreateNewPasswordCubit(
    this._resetPasswordUseCase, {
    required String email,
    required String code,
  }) : super(CreateNewPasswordState(email: email, code: code));

  void passwordChanged(String value) {
    emit(state.copyWith(password: value));
  }

  void confirmPasswordChanged(String value) {
    emit(state.copyWith(confirmPassword: value));
  }

  Future<void> submit({required bool Function() isFormValid}) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(hasTriedSubmit: true));

    if (!isFormValid()) return;

    emit(state.copyWith(status: CreateNewPasswordStatus.submitting));

    final result = await _resetPasswordUseCase(
      ResetPasswordParams(
        email: state.email,
        code: state.code,
        password: state.password,
        confirmPassword: state.confirmPassword,
      ),
    );

    switch (result) {
      case Ok():
        emit(state.copyWith(status: CreateNewPasswordStatus.success));

      case Err(:final failure):
        emit(
          state.copyWith(
            status: CreateNewPasswordStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
