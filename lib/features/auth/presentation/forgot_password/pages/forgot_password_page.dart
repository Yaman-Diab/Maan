import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maan/core/di/service_locator.dart';

import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import '../widgets/forgot_password_form.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.onCodeSent});

  /// بتنادى بعد إرسال رمز إعادة التعيين — المتوقّع الانتقال لشاشة
  /// كلمة المرور الجديدة ومعها البريد.
  final void Function(String email)? onCodeSent;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, ForgotPasswordState state) {
    switch (state.status) {
      case ForgotPasswordStatus.success:
        widget.onCodeSent?.call(state.email);

      case ForgotPasswordStatus.failure:
        final message = state.errorMessage;
        if (message == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));

      case ForgotPasswordStatus.initial:
      case ForgotPasswordStatus.submitting:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordCubit>(
      create: (_) => sl<ForgotPasswordCubit>(),
      child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: _onStateChanged,
        builder: (context, state) {
          return ForgotPasswordForm(
            formKey: _formKey,
            emailController: _emailController,
            state: state,
          );
        },
      ),
    );
  }
}
