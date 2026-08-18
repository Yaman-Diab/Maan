// -------------------------
// Verification Cubit
// -------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/media/picked_image.dart';
import '../../../../../core/result/result.dart';
import '../../../../../core/session/account_status.dart';
import '../../../../../core/session/app_session_controller.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../../auth/domain/entities/auth_user.dart';
import '../../../../profile/domain/usecases/get_profile_usecase.dart';
import '../../../domain/entities/verification_request.dart';
import '../../../domain/usecases/get_verification_status_usecase.dart';
import '../../../domain/usecases/submit_verification_usecase.dart';
import '../../../domain/usecases/update_verification_usecase.dart';
import 'verification_state.dart';

/// شاشة واحدة بأربعة عروض (نموذج · قيد المراجعة · مرفوض · معتمد) —
/// مش أربع شاشات، لأن العرض بيتحدّد من حالة الطلب لا من ملاحة المستخدم:
/// هو دايماً بيوصل من نفس المكان وبيشوف وين صار طلبه.
class VerificationCubit extends Cubit<VerificationState> {
  final GetVerificationStatusUseCase _getStatus;
  final GetProfileUseCase _getProfile;
  final SubmitVerificationUseCase _submit;
  final UpdateVerificationUseCase _update;
  final AppSessionController _session;

  VerificationCubit(
    this._getStatus,
    this._getProfile,
    this._submit,
    this._update,
    this._session,
  ) : super(const VerificationState());

  /// بتتنادى عند فتح الشاشة، وعند إعادة المحاولة، وعند الرجوع من شاشة
  /// تعديل الهوية (فبطاقة البيانات الشخصية بتعرض القيم الجديدة).
  Future<void> load() async {
    emit(state.copyWith(view: VerificationView.loading));

    // بيتبعتوا سوا لأنهم مستقلان تماماً — تسلسلهما بيضاعف زمن الفتح بلا
    // فايدة. الانتظار بعدين بدل `Future.wait` حتى يضل كل نوع معروفاً
    // بدل قائمة `dynamic`.
    final statusFuture = _getStatus(const NoParams());
    final profileFuture = _getProfile(const NoParams());

    final statusResult = await statusFuture;
    final profileResult = await profileFuture;

    if (isClosed) return;

    // فشل الملف الشخصي **ما بيوقّع الشاشة**: البطاقة عرض مساعد،
    // والتوثيق نفسه ما بيعتمد عليها. بتختفي البطاقة وبس.
    final AuthUser? user = switch (profileResult) {
      Ok(:final value) => value.user,
      Err() => null,
    };

    switch (statusResult) {
      case Ok(:final value):
        emit(
          (value == null
                  ? const VerificationState(view: VerificationView.form)
                  : _stateForRequest(value))
              .copyWith(user: user),
        );

      case Err(:final failure):
        emit(
          state.copyWith(
            view: VerificationView.loadFailure,
            user: user,
            errorMessage: failure.message,
          ),
        );
    }
  }

  void nationalIdChanged(String value) {
    emit(state.copyWith(nationalId: value));
  }

  void imagePicked(DocumentSlot slot, PickedImage image) {
    emit(switch (slot) {
      DocumentSlot.front => state.copyWith(frontImage: image),
      DocumentSlot.selfie => state.copyWith(selfieImage: image),
    });
  }

  void imageRemoved(DocumentSlot slot) {
    emit(switch (slot) {
      DocumentSlot.front => state.copyWith(clearFrontImage: true),
      DocumentSlot.selfie => state.copyWith(clearSelfieImage: true),
    });
  }

  /// الرجوع من «قيد المراجعة» للنموذج لتصحيح الرقم الوطني. الطلب بيضل
  /// بالحالة (`request`) — هو اللي بيخلّي [VerificationState.isEditingExisting]
  /// تشتغل فتُرسل `update` بدل `store`.
  void editRequested() {
    emit(
      state.copyWith(
        view: VerificationView.form,
        submission: VerificationSubmission.idle,
        nationalId: state.request?.nationalId ?? state.nationalId,
      ),
    );
  }

  /// إعادة إرسال بعد رفض — على عكس [editRequested] بتمسح الطلب القديم
  /// والصور: الرفض معناه طلب **جديد** كامل (`store`)، مش تصحيح طلب قائم.
  void resubmitRequested() {
    emit(
      VerificationState(
        view: VerificationView.form,
        // الرقم الوطني بيضل مبدئياً: غالباً صح والرفض كان بسبب الصور،
        // فإعادة كتابته من الصفر احتكاك بلا سبب.
        nationalId: state.request?.nationalId ?? '',
      ),
    );
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;

    emit(state.copyWith(submission: VerificationSubmission.submitting));

    final nationalId = state.nationalId.trim();
    final existing = state.request;

    final result = state.isEditingExisting && existing != null
        ? await _update(
            UpdateVerificationParams(
              requestId: existing.id,
              nationalId: nationalId,
            ),
          )
        : await _submit(
            SubmitVerificationParams(
              nationalId: nationalId,
              images: [state.frontImage!, state.selfieImage!],
            ),
          );

    if (isClosed) return;

    switch (result) {
      case Ok(:final value):
        emit(
          _stateForRequest(
            value,
          ).copyWith(submission: VerificationSubmission.success),
        );

      case Err(:final failure):
        emit(
          state.copyWith(
            submission: VerificationSubmission.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  /// العرض بيتحدّد من حالة الطلب. [VerificationRequestStatus.unknown]
  /// بتوقع على النموذج عن قصد — قيمة ما بنعرفها ما لازم تقفل المستخدم
  /// برّا شاشة بيقدر يستخدمها (راجع تعليق الـ enum).
  VerificationState _stateForRequest(VerificationRequest request) {
    final status = request.status;

    if (status.isApproved) {
      // الطلب اعتُمد يعني حالة الحساب تغيّرت بالباك اند — نفس منطق
      // `ProfileCubit.load`: الشاشة اللي بتشوف الحقيقة الأحدث هي اللي
      // بتبلّغ الجلسة، فحراسة المسارات بتتحدّث بلا سطر إضافي.
      _session.accountStatusChanged(AccountStatus.verified);
    }

    return VerificationState(
      view: switch (status) {
        _ when status.isApproved => VerificationView.approved,
        _ when status.isRejected => VerificationView.rejected,
        _ when status.isPending => VerificationView.pending,
        _ => VerificationView.form,
      },
      request: request,
      nationalId: request.nationalId,
    );
  }
}
