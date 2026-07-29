// -------------------------
// Sign Up Cubit
// -------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/result/result.dart';
import '../../../domain/entities/birth_date.dart';
import '../../../domain/usecases/register_usecase.dart';
import 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final RegisterUseCase _registerUseCase;

  SignUpCubit(this._registerUseCase) : super(const SignUpState());

  void firstNameChanged(String value) {
    emit(state.copyWith(firstName: value.trim()));
  }

  void lastNameChanged(String value) {
    emit(state.copyWith(lastName: value.trim()));
  }

  void emailChanged(String value) {
    emit(state.copyWith(email: value.trim()));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value));
  }

  void confirmPasswordChanged(String value) {
    emit(state.copyWith(confirmPassword: value));
  }

  void termsToggled(bool value) {
    emit(state.copyWith(isTermsAccepted: value));
  }

  // -------------------------
  // Birth Date
  // -------------------------

  void dayChanged(int value) {
    emit(state.copyWith(day: value));
  }

  /// تغيير الشهر أو السنة ممكن يخلّي اليوم المختار غير موجود
  /// (مثلاً 31 ثم شهر فيه 30 يوم)، فبنقصّه للحد الأعلى.
  void monthChanged(int value) {
    emit(state.copyWith(month: value, day: _clampedDay(month: value)));
  }

  void yearChanged(int value) {
    emit(state.copyWith(year: value, day: _clampedDay(year: value)));
  }

  int? _clampedDay({int? month, int? year}) {
    final day = state.day;
    if (day == null) return null;

    final maxDay = BirthDate.daysInMonth(
      year ?? state.year ?? BirthDate.maxAllowedYear(),
      month ?? state.month ?? DateTime.now().month,
    );

    return day > maxDay ? maxDay : day;
  }

  // -------------------------
  // Submit
  // -------------------------

  Future<void> submit({required bool Function() isFormValid}) async {
    if (!state.canSubmit) return;

    final birthDateError = BirthDate.validateParts(
      day: state.day,
      month: state.month,
      year: state.year,
    );

    emit(state.copyWith(hasTriedSubmit: true, birthDateError: birthDateError));

    if (!isFormValid() || birthDateError != null) return;

    emit(state.copyWith(status: SignUpStatus.submitting));

    final result = await _registerUseCase(
      RegisterParams(
        firstName: state.firstName,
        lastName: state.lastName,
        birthDate: BirthDate(
          day: state.day!,
          month: state.month!,
          year: state.year!,
        ),
        email: state.email,
        password: state.password,
      ),
    );

    switch (result) {
      case Ok():
        emit(state.copyWith(status: SignUpStatus.success));

      case Err(:final failure):
        emit(
          state.copyWith(
            status: SignUpStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
