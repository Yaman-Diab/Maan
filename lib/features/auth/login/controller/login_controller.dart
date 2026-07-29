import 'package:flutter/material.dart';
import 'package:maan/core/network/api_exception.dart';

import '../models/login_payload.dart';

class LoginController extends ChangeNotifier {
  LoginController() {
    emailController.addListener(_updateCanSubmit);
    passwordController.addListener(_updateCanSubmit);
  }

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isSubmitting = false;
  bool canSubmit = false;
  bool isTermsAccepted = false;
  bool hasTriedSubmit = false;

  AutovalidateMode get autovalidateMode {
    return hasTriedSubmit
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;
  }

  bool get _isFormReady {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final areFieldsFilled = email.isNotEmpty && password.isNotEmpty;

    return areFieldsFilled && isTermsAccepted && !isSubmitting;
  }

  void setTermsAccepted(bool value) {
    if (isTermsAccepted == value) return;

    isTermsAccepted = value;

    final nextValue = _isFormReady;
    final shouldUpdateCanSubmit = nextValue != canSubmit;

    if (shouldUpdateCanSubmit) {
      canSubmit = nextValue;
    }

    notifyListeners();
  }

  void _updateCanSubmit() {
    final nextValue = _isFormReady;

    if (nextValue == canSubmit) return;

    canSubmit = nextValue;
    notifyListeners();
  }

  Future<void> submit({
    required Future<void> Function(LoginPayload payload) onSubmit,
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
      final payload = LoginPayload(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await onSubmit(payload);
    } on ApiException catch (exception) {
      onError(exception.userMessage);
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
    passwordController.removeListener(_updateCanSubmit);

    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }
}
