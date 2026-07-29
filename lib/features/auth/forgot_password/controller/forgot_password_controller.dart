import 'package:flutter/material.dart';

import '../models/forgot_password_payload.dart';

class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController() {
    emailController.addListener(_updateCanSubmit);
  }

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();

  bool isSubmitting = false;
  bool canSubmit = false;
  bool hasTriedSubmit = false;

  AutovalidateMode get autovalidateMode {
    return hasTriedSubmit
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;
  }

  bool get _isFormReady {
    final email = emailController.text.trim();

    return email.isNotEmpty && !isSubmitting;
  }

  void _updateCanSubmit() {
    final nextValue = _isFormReady;

    if (nextValue == canSubmit) return;

    canSubmit = nextValue;
    notifyListeners();
  }

  Future<void> submit({
    required Future<void> Function(ForgotPasswordPayload payload) onSubmit,
    required void Function(String message) onError,
  }) async {
    if (!canSubmit || isSubmitting) return;

    hasTriedSubmit = true;
    notifyListeners();

    final isFormValid = formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      _updateCanSubmit();
      return;
    }

    isSubmitting = true;
    canSubmit = false;
    notifyListeners();

    try {
      final payload = ForgotPasswordPayload(
        email: emailController.text.trim(),
      );

      await onSubmit(payload);
    } catch (_) {
      onError('Something went wrong. Please try again.');
    } finally {
      isSubmitting = false;
      _updateCanSubmit();
    }
  }

  @override
  void dispose() {
    emailController.removeListener(_updateCanSubmit);
    emailController.dispose();

    super.dispose();
  }
}
