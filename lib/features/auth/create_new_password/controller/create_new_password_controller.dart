import 'package:flutter/material.dart';

import '../models/create_new_password_payload.dart';

class CreateNewPasswordController extends ChangeNotifier {
  CreateNewPasswordController() {
    _addInputListeners();
  }

  final formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isSubmitting = false;
  bool hasTriedSubmit = false;

  bool get canSubmit => _areFieldsFilled && !isSubmitting;

  AutovalidateMode get autovalidateMode {
    return hasTriedSubmit
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;
  }

  bool get _areFieldsFilled {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    return password.isNotEmpty && confirmPassword.isNotEmpty;
  }

  CreateNewPasswordPayload get payload {
    return CreateNewPasswordPayload(
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );
  }

  Future<void> submit({
    required Future<void> Function(CreateNewPasswordPayload payload) onSubmit,
  }) async {
    if (!canSubmit || isSubmitting) return;

    hasTriedSubmit = true;
    notifyListeners();

    final isFormValid = formKey.currentState?.validate() ?? false;

    if (!isFormValid) return;

    isSubmitting = true;
    notifyListeners();

    try {
      await onSubmit(payload);
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void _addInputListeners() {
    passwordController.addListener(_handleInputChanged);
    confirmPasswordController.addListener(_handleInputChanged);
  }

  void _removeInputListeners() {
    passwordController.removeListener(_handleInputChanged);
    confirmPasswordController.removeListener(_handleInputChanged);
  }

  void _handleInputChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _removeInputListeners();

    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }
}
