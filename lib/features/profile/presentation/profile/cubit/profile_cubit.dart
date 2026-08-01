// -------------------------
// Profile Cubit
// -------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/result/result.dart';
import '../../../../../core/session/app_session_controller.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/get_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfile;
  final AppSessionController _session;

  ProfileCubit(this._getProfile, this._session) : super(const ProfileState());

  /// بتتنادى عند فتح الشاشة وعند السحب للتحديث.
  Future<void> load() async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await _getProfile(const NoParams());

    if (isClosed) return;

    switch (result) {
      case Ok(:final value):
        // `/api/profile` هو المصدر الأحدث لحالة الحساب — أحدث من نسخة
        // وقت الدخول، لأن التوثيق ممكن يكون اعتُمد بعدها. `AppRedirect`
        // بيسمع لهالمتحكّم، فحراسة المسارات بتتحدّث بلا سطر إضافي.
        _session.accountStatusChanged(value.user.accountStatus);

        emit(state.copyWith(status: ProfileStatus.success, profile: value));

      case Err(:final failure):
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
