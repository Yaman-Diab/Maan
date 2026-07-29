import 'package:flutter/material.dart';

import 'package:maan/core/di/service_locator.dart';
import 'package:maan/core/session/app_session_controller.dart';
import 'package:maan/core/storage/secure_storage_service.dart';
import 'package:maan/features/auth/auth_repository.dart';
import 'controller/login_controller.dart';
import 'models/login_payload.dart';
import 'widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onSubmit,
    this.onForgotPasswordTap,
    this.onSignUpTap,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final Future<void> Function(LoginPayload payload)? onSubmit;
  final VoidCallback? onForgotPasswordTap;
  final VoidCallback? onSignUpTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = LoginController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submit(LoginPayload payload) async {
    if (widget.onSubmit != null) {
      await widget.onSubmit!(payload);
      return;
    }

    final authRepository = sl<AuthRepository>();
    final storage = sl<SecureStorageService>();
    final sessionController = sl<AppSessionController>();

    final loginResponse = await authRepository.login(payload);

    await storage.saveTokens(
      accessToken: loginResponse.accessToken,
      refreshToken: loginResponse.refreshToken,
    );

    if (loginResponse.user != null && loginResponse.user!.isNotEmpty) {
      await storage.saveUser(loginResponse.user!);
    }

    await sessionController.loginCompleted();

    debugPrint('Login response: $loginResponse');
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
        return LoginForm(
          controller: controller,
          onSubmit: _submit,
          onError: _showErrorMessage,
          onForgotPasswordTap: widget.onForgotPasswordTap,
          onSignUpTap: widget.onSignUpTap,
          onTermsTap: widget.onTermsTap,
          onPrivacyTap: widget.onPrivacyTap,
        );
      },
    );
  }
}
