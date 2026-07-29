import 'dart:async';

import 'package:flutter/material.dart';

import '../models/verify_email_payload.dart';

class VerifyEmailController extends ChangeNotifier {
  VerifyEmailController({
    required this.email,
    this.codeLength = 6,
    int initialRemainingSeconds = 59,
  }) : _remainingSeconds = initialRemainingSeconds {
    pinController.addListener(_onCodeChanged);
    _startTimer();
  }

  final String email;
  final int codeLength;

  final pinController = TextEditingController();
  final pinFocusNode = FocusNode();

  Timer? _timer;
  int _remainingSeconds;

  bool isSubmitting = false;
  bool isResending = false;
  bool canSubmit = false;
  bool hasTriedSubmit = false;
  bool hasPinError = false;
  bool isHelpVisible = false;
  String? pinErrorText;

  int get remainingSeconds => _remainingSeconds;
  bool get canResend => _remainingSeconds == 0 && !isResending;

  bool get _isCodeComplete {
    return pinController.text.trim().length == codeLength;
  }

  void _onCodeChanged() {
    var shouldNotify = false;

    if (hasPinError) {
      hasPinError = false;
      pinErrorText = null;
      shouldNotify = true;
    }

    final nextValue = _isCodeComplete && !isSubmitting;

    if (nextValue != canSubmit) {
      canSubmit = nextValue;
      shouldNotify = true;
    }

    if (shouldNotify) notifyListeners();
  }

  void toggleHelp() {
    isHelpVisible = !isHelpVisible;
    notifyListeners();
  }

  String? _validateCode() {
    final code = pinController.text.trim();

    if (code.isEmpty) {
      return 'Verification code is required';
    }

    if (code.length != codeLength) {
      return 'Please enter the $codeLength-digit verification code';
    }

    if (!RegExp(r'^\d+$').hasMatch(code)) {
      return 'Verification code must contain digits only';
    }

    return null;
  }

  Future<void> submit({
    required Future<void> Function(VerifyEmailPayload payload) onSubmit,
    required void Function(String message) onError,
  }) async {
    if (!canSubmit || isSubmitting) return;

    pinFocusNode.unfocus();

    hasTriedSubmit = true;

    final error = _validateCode();

    if (error != null) {
      hasPinError = true;
      pinErrorText = error;
      notifyListeners();
      return;
    }

    isSubmitting = true;
    canSubmit = false;
    hasPinError = false;
    pinErrorText = null;
    notifyListeners();

    try {
      final payload = VerifyEmailPayload(
        email: email,
        code: pinController.text.trim(),
      );

      await onSubmit(payload);
    } catch (_) {
      hasPinError = true;
      pinErrorText = 'Invalid verification code';
      onError('Invalid verification code. Please try again.');
    } finally {
      isSubmitting = false;
      canSubmit = _isCodeComplete;
      notifyListeners();
    }
  }

  Future<void> resendCode({
    required Future<void> Function() onResendCode,
    required void Function(String message) onError,
  }) async {
    if (!canResend || isResending) return;

    isResending = true;
    notifyListeners();

    try {
      await onResendCode();

      pinController.clear();
      hasPinError = false;
      pinErrorText = null;
      _restartTimer();
    } catch (_) {
      onError('Could not resend the code. Please try again.');
    } finally {
      isResending = false;
      canSubmit = _isCodeComplete && !isSubmitting;
      notifyListeners();
    }
  }

  void setServerError(String message) {
    hasPinError = true;
    pinErrorText = message;
    notifyListeners();
  }

  void _restartTimer() {
    _remainingSeconds = 59;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    if (_remainingSeconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        _remainingSeconds = 0;
        timer.cancel();
        notifyListeners();
        return;
      }

      _remainingSeconds--;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    pinController.removeListener(_onCodeChanged);
    pinController.dispose();
    pinFocusNode.dispose();
    super.dispose();
  }
}
