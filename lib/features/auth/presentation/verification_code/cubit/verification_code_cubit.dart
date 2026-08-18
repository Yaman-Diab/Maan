// -------------------------
// Verification Code Cubit
// -------------------------

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/result/result.dart';
import '../../../domain/usecases/check_code_usecase.dart';
import 'verification_code_state.dart';

/// المنطق المشترك لشاشات إدخال رمز التحقق: العدّ التنازلي، تنسيق الرمز،
/// إرسال التحقق، وتصنيف الأخطاء بين «تحت الخانات» و«SnackBar».
///
/// الشاشات بتختلف بشغلة وحدة بس — **مصدر إعادة الإرسال** — فهي المجرَّدة
/// الوحيدة هون ([performResend]). أي شي تاني مشترك حرفياً، فنسخه مرتين
/// كان بيعني مؤقّتَين وتحقّقَين لازم يضلوا متطابقين يدوياً.
abstract class VerificationCodeCubit extends Cubit<VerificationCodeState> {
  final CheckCodeUseCase _checkCodeUseCase;

  /// مدة الانتظار قبل السماح بإعادة الإرسال.
  final int cooldownSeconds;

  // الوسيط عام الاسم (لا `this._checkCodeUseCase`) حتى تقدر الصفوف
  // الوارثة تمرّره بـ`super.checkCodeUseCase` — الأسماء الخاصة ما
  // بتنشاف من مكتبة تانية.
  VerificationCodeCubit(
    CheckCodeUseCase checkCodeUseCase, {
    required String email,
    int codeLength = 6,
    this.cooldownSeconds = 59,
  }) : _checkCodeUseCase = checkCodeUseCase,
       super(
         VerificationCodeState(
           email: email,
           codeLength: codeLength,
           remainingSeconds: cooldownSeconds,
         ),
       ) {
    _startTimer();
  }

  Timer? _timer;

  /// كيف بينعاد إرسال الرمز — تأكيد البريد بيضرب endpoint غير اللي
  /// بتضربه استعادة كلمة المرور.
  Future<Result<void>> performResend();

  void codeChanged(String value) {
    // إدخال جديد بيلغي خطأ الرمز السابق.
    emit(state.copyWith(code: value));
  }

  void toggleHelp() {
    emit(
      state.copyWith(
        isHelpVisible: !state.isHelpVisible,
        codeError: state.codeError,
      ),
    );
  }

  // -------------------------
  // Submit
  // -------------------------

  Future<void> submit() async {
    if (!state.canSubmit) return;

    final codeError = _codeFormatError();

    if (codeError != null) {
      emit(state.copyWith(codeError: codeError));
      return;
    }

    emit(state.copyWith(status: VerificationCodeStatus.submitting));

    // الـ backend بيعرف صاحب الرمز من الجلسة، فما بيتبعت البريد معه.
    final result = await _checkCodeUseCase(
      CheckCodeParams(code: state.code.trim()),
    );

    if (isClosed) return;

    switch (result) {
      case Ok():
        emit(state.copyWith(status: VerificationCodeStatus.success));

      case Err(:final failure):
        // أخطاء الرمز بتظهر تحت الخانات، والباقي كـ SnackBar.
        final isCodeProblem = failure is OtpFailure;

        emit(
          state.copyWith(
            status: VerificationCodeStatus.failure,
            codeError: isCodeProblem ? failure.message : null,
            errorMessage: isCodeProblem ? null : failure.message,
          ),
        );
    }
  }

  // -------------------------
  // Resend
  // -------------------------

  Future<void> resendCode() async {
    if (!state.canResend) return;

    emit(state.copyWith(isResending: true));

    final result = await performResend();

    if (isClosed) return;

    switch (result) {
      case Ok():
        emit(
          state.copyWith(
            isResending: false,
            code: '',
            remainingSeconds: cooldownSeconds,
          ),
        );
        _startTimer();

      case Err(:final failure):
        emit(state.copyWith(isResending: false, errorMessage: failure.message));
    }
  }

  // -------------------------
  // Countdown
  // -------------------------

  void _startTimer() {
    _timer?.cancel();

    if (state.remainingSeconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.remainingSeconds - 1;

      if (next <= 0) {
        timer.cancel();
      }

      emit(
        state.copyWith(
          remainingSeconds: next < 0 ? 0 : next,
          codeError: state.codeError,
          errorMessage: state.errorMessage,
        ),
      );
    });
  }

  String? _codeFormatError() {
    final code = state.code.trim();

    if (code.isEmpty) {
      return 'code_required'.tr();
    }

    if (code.length != state.codeLength) {
      return 'code_length_error'.tr(
        namedArgs: {'length': '${state.codeLength}'},
      );
    }

    if (!RegExp(r'^\d+$').hasMatch(code)) {
      return 'code_digits_only'.tr();
    }

    return null;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
