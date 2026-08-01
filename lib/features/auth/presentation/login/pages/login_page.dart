import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maan/core/di/service_locator.dart';
import 'package:maan/core/session/app_session_controller.dart';

import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onForgotPasswordTap,
    this.onSignUpTap,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final VoidCallback? onForgotPasswordTap;
  final VoidCallback? onSignUpTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, LoginState state) {
    switch (state.status) {
      // حفظ التوكنات صار داخل LoginUseCase؛ الباقي هون هو إعلام
      // AppSessionController اللي بيغذّي refreshListenable تبع GoRouter
      // فيتم التوجيه للرئيسية.
      case LoginStatus.success:
        sl<AppSessionController>().loginCompleted(
          accountStatus: state.accountStatus,
        );

      case LoginStatus.failure:
        final message = state.errorMessage;
        if (message == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));

      case LoginStatus.initial:
      case LoginStatus.submitting:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (_) => sl<LoginCubit>(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: _onStateChanged,
        builder: (context, state) {
          return LoginForm(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
            state: state,
            onForgotPasswordTap: widget.onForgotPasswordTap,
            onSignUpTap: widget.onSignUpTap,
            onTermsTap: widget.onTermsTap,
            onPrivacyTap: widget.onPrivacyTap,
          );
        },
      ),
    );
  }
}
