import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maan/core/di/service_locator.dart';

import '../../verification_code/cubit/verification_code_state.dart';
import '../cubit/verify_reset_code_cubit.dart';
import '../widgets/verify_reset_code_form.dart';

/// الخطوة الناقصة بين «نسيت كلمة المرور» و«كلمة المرور الجديدة».
class VerifyResetCodePage extends StatefulWidget {
  const VerifyResetCodePage({
    super.key,
    required this.email,
    this.onCodeVerified,
  });

  final String email;

  /// بتنادى بالرمز **بعد** ما يأكّده السيرفر — الشاشة الجاية بتحتاجه
  /// لأن `POST /api/auth/resetPassword` بيطلبه مع كلمة المرور الجديدة.
  final void Function(String code)? onCodeVerified;

  @override
  State<VerifyResetCodePage> createState() => _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends State<VerifyResetCodePage> {
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, VerificationCodeState state) {
    // إعادة إرسال ناجحة بتفرّغ الرمز بالحالة، فبنعكسها على الحقل.
    if (state.code.isEmpty && _pinController.text.isNotEmpty) {
      _pinController.clear();
    }

    switch (state.status) {
      case VerificationCodeStatus.success:
        widget.onCodeVerified?.call(state.code.trim());

      case VerificationCodeStatus.failure:
        final message = state.errorMessage;
        if (message == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));

      case VerificationCodeStatus.initial:
      case VerificationCodeStatus.submitting:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VerifyResetCodeCubit>(
      create: (_) => sl<VerifyResetCodeCubit>(param1: widget.email),
      child: BlocConsumer<VerifyResetCodeCubit, VerificationCodeState>(
        listener: _onStateChanged,
        builder: (context, state) {
          return VerifyResetCodeForm(
            state: state,
            pinController: _pinController,
            pinFocusNode: _pinFocusNode,
          );
        },
      ),
    );
  }
}
