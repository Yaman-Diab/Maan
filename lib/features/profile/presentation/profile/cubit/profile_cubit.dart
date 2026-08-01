// -------------------------
// Profile Cubit
// -------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/media/picked_image.dart';
import '../../../../../core/result/result.dart';
import '../../../../../core/session/app_session_controller.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/get_profile_usecase.dart';
import '../../../domain/usecases/upload_avatar_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfile;
  final UploadAvatarUseCase _uploadAvatar;
  final AppSessionController _session;

  ProfileCubit(this._getProfile, this._uploadAvatar, this._session)
    : super(const ProfileState());

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

  /// رفع صورة جاهزة (مقصوصة ومضغوطة) جاية من `ImagePickerService`.
  ///
  /// الصورة بتبيّن **قبل** ما يرد السيرفر: المستخدم لسه شايفها بشاشة
  /// القص، فإخفاؤها لحد ما يخلص الرفع بيحسّ كأن شي وقع. ولو فشل الرفع
  /// بترجع الصورة القديمة — عرض صورة السيرفر ما استلمها كذبة.
  Future<void> uploadAvatar(PickedImage image) async {
    emit(
      state.copyWith(localAvatarPath: image.path, isUploadingAvatar: true),
    );

    final result = await _uploadAvatar(
      UploadAvatarParams(bytes: image.bytes, fileName: image.fileName),
    );

    if (isClosed) return;

    switch (result) {
      case Ok():
        emit(state.copyWith(isUploadingAvatar: false));

      case Err(:final failure):
        emit(
          state.copyWith(
            clearLocalAvatar: true,
            isUploadingAvatar: false,
            avatarErrorMessage: failure.message,
          ),
        );
    }
  }
}
