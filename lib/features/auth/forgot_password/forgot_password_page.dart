import 'package:flutter/material.dart';

import 'controller/forgot_password_controller.dart';
import 'models/forgot_password_payload.dart';
import 'widgets/forgot_password_form.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
    this.onSubmit,
  });

  final Future<void> Function(ForgotPasswordPayload payload)? onSubmit;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final ForgotPasswordController controller;

  @override
  void initState() {
    super.initState();
    controller = ForgotPasswordController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submit(ForgotPasswordPayload payload) async {
    if (widget.onSubmit != null) {
      await widget.onSubmit!(payload);
      return;
    }

    // TODO: Call your forgot password API / Cubit here.
    // Example:
    // await context.read<AuthCubit>().forgotPassword(payload.toMap());

    debugPrint(payload.toString());
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ForgotPasswordForm(
          controller: controller,
          onSubmit: _submit,
          onError: _showErrorMessage,
        );
      },
    );
  }
}
