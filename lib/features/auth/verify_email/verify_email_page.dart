import 'package:flutter/material.dart';

import 'controller/verify_email_controller.dart';
import 'models/verify_email_payload.dart';
import 'widgets/verify_email_form.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({
    super.key,
    required this.email,
    this.onSubmit,
    this.onResendCode,
  });

  final String email;
  final Future<void> Function(VerifyEmailPayload payload)? onSubmit;
  final Future<void> Function()? onResendCode;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  late final VerifyEmailController controller;

  @override
  void initState() {
    super.initState();

    controller = VerifyEmailController(email: widget.email);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submit(VerifyEmailPayload payload) async {
    if (widget.onSubmit != null) {
      await widget.onSubmit!(payload);
      return;
    }

    // TODO: Call your verify email API / Cubit here.
    // Example:
    // await context.read<AuthCubit>().verifyEmail(payload.toMap());

    debugPrint(payload.toString());
  }

  Future<void> _resendCode() async {
    if (widget.onResendCode != null) {
      await widget.onResendCode!();
      return;
    }

    // TODO: Call your resend code API / Cubit here.
    // Example:
    // await context.read<AuthCubit>().resendVerificationCode(widget.email);

    debugPrint('Resend verification code to ${widget.email}');
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
        return VerifyEmailForm(
          controller: controller,
          onSubmit: _submit,
          onResendCode: _resendCode,
          onError: _showErrorMessage,
        );
      },
    );
  }
}
