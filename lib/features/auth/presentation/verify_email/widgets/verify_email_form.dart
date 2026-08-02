import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../verification_code/cubit/verification_code_state.dart';
import '../../verification_code/widgets/verification_code_scaffold.dart';
import '../../verification_code/widgets/verification_submit_button.dart';
import '../cubit/verify_email_cubit.dart';
import 'verify_email_header.dart';

class VerifyEmailForm extends StatelessWidget {
  const VerifyEmailForm({
    super.key,
    required this.state,
    required this.pinController,
    required this.pinFocusNode,
  });

  final VerificationCodeState state;
  final TextEditingController pinController;
  final FocusNode pinFocusNode;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VerifyEmailCubit>();

    return VerificationCodeScaffold(
      state: state,
      pinController: pinController,
      pinFocusNode: pinFocusNode,
      header: VerifyEmailHeader(email: state.email),
      submitLabel: VerificationSubmitButton(
        canSubmit: state.canSubmit,
        isSubmitting: state.isSubmitting,
        label: 'verify_email_button'.tr(),
        submittingLabel: 'verifying'.tr(),
        onPressed: () {
          FocusScope.of(context).unfocus();
          cubit.submit();
        },
      ),
      onCodeChanged: cubit.codeChanged,
      onSubmit: cubit.submit,
      onResend: cubit.resendCode,
      onToggleHelp: cubit.toggleHelp,
    );
  }
}
