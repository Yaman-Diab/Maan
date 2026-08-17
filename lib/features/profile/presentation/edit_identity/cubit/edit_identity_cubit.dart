// -------------------------
// Edit Identity Cubit
// -------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/result/result.dart';
import '../../../../../core/session/account_status.dart';
import '../../../../auth/domain/entities/auth_user.dart';
import 'package:maan/core/domain/birth_date.dart';
import '../../../domain/usecases/update_identity_usecase.dart';
import 'edit_identity_state.dart';

class EditIdentityCubit extends Cubit<EditIdentityState> {
  final UpdateIdentityUseCase _updateIdentityUseCase;

  /// بيتعبّى من [user] الحالي — تعديل لا إنشاء من الصفر.
  EditIdentityCubit(this._updateIdentityUseCase, {required AuthUser user})
    : super(
        EditIdentityState(
          firstName: user.firstName,
          lastName: user.lastName,
          nationalId: user.nationalId ?? '',
          day: user.birthDate?.day,
          month: user.birthDate?.month,
          year: user.birthDate?.year,
          isLocked: user.accountStatus == AccountStatus.verified,
        ),
      );

  void firstNameChanged(String value) {
    emit(state.copyWith(firstName: value));
  }

  void lastNameChanged(String value) {
    emit(state.copyWith(lastName: value));
  }

  // ما في `nationalIdChanged`: الرقم الوطني بينحمل بالحالة وبينبعت كما
  // وصل، بس ما بينعدّل من هون — شاشة التوثيق هي مالكته الوحيدة.

  // -------------------------
  // Birth Date — نفس منطق SignUpCubit بالضبط.
  // -------------------------

  void dayChanged(int value) {
    emit(state.copyWith(day: value));
  }

  void monthChanged(int value) {
    emit(
      state.copyWith(
        month: value,
        day: _clampedDay(month: value),
      ),
    );
  }

  void yearChanged(int value) {
    emit(
      state.copyWith(
        year: value,
        day: _clampedDay(year: value),
      ),
    );
  }

  int? _clampedDay({int? month, int? year}) {
    return BirthDate.clampDay(
      day: state.day,
      month: month ?? state.month,
      year: year ?? state.year,
    );
  }

  // -------------------------
  // Submit
  // -------------------------

  Future<void> submit({required bool Function() isFormValid}) async {
    if (state.isLocked || state.isSubmitting) return;

    final birthDateError = BirthDate.validateParts(
      day: state.day,
      month: state.month,
      year: state.year,
    );

    // `hasTriedSubmit` قبل `isFormValid()` عمداً — هو يلي بيفعّل
    // `AutovalidateMode.onUserInteraction`، فلازم يكون فعّال وقت
    // النداء حتى تظهر رسائل التحقق فوراً.
    emit(state.copyWith(hasTriedSubmit: true, birthDateError: birthDateError));

    if (!isFormValid() || birthDateError != null) return;

    emit(state.copyWith(status: EditIdentityStatus.submitting));

    final result = await _updateIdentityUseCase(
      UpdateIdentityParams(
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        nationalId: state.nationalId.trim(),
        birthDate: BirthDate(
          day: state.day!,
          month: state.month!,
          year: state.year!,
        ),
      ),
    );

    if (isClosed) return;

    switch (result) {
      case Ok():
        emit(state.copyWith(status: EditIdentityStatus.success));

      case Err(:final failure):
        emit(
          state.copyWith(
            status: EditIdentityStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
