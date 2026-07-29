import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maan/core/di/service_locator.dart';

import '../cubit/verify_email_cubit.dart';
import '../cubit/verify_email_state.dart';
import '../widgets/verify_email_form.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key, required this.email, this.onVerified});

  final String email;

  /// بتنادى بعد نجاح التحقق — المتوقّع الانتقال لتسجيل الدخول.
  final VoidCallback? onVerified;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, VerifyEmailState state) {
    // إعادة إرسال ناجحة بتفرّغ الرمز بالحالة، فبنعكسها على الحقل.
    if (state.code.isEmpty && _pinController.text.isNotEmpty) {
      _pinController.clear();
    }

    switch (state.status) {
      case VerifyEmailStatus.success:
        widget.onVerified?.call();

      case VerifyEmailStatus.failure:
        final message = state.errorMessage;
        if (message == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));

      case VerifyEmailStatus.initial:
      case VerifyEmailStatus.submitting:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VerifyEmailCubit>(
      create: (_) => sl<VerifyEmailCubit>(param1: widget.email),
      child: BlocConsumer<VerifyEmailCubit, VerifyEmailState>(
        listener: _onStateChanged,
        builder: (context, state) {
          return VerifyEmailForm(
            state: state,
            pinController: _pinController,
            pinFocusNode: _pinFocusNode,
          );
        },
      ),
    );
  }
}
