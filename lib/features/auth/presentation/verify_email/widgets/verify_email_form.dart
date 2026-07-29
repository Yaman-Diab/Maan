import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_colors.dart';

import '../cubit/verify_email_cubit.dart';
import '../cubit/verify_email_state.dart';
import 'resend_code_section.dart';
import 'verification_code_input.dart';
import 'verification_help_box.dart';
import 'verification_help_link.dart';
import 'verify_email_header.dart';
import 'verify_email_submit_button.dart';

class VerifyEmailForm extends StatelessWidget {
  const VerifyEmailForm({
    super.key,
    required this.state,
    required this.pinController,
    required this.pinFocusNode,
  });

  final VerifyEmailState state;
  final TextEditingController pinController;
  final FocusNode pinFocusNode;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VerifyEmailCubit>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            children: [
              SizedBox(height: 68.h),

              VerifyEmailHeader(email: state.email),

              SizedBox(height: 38.h),

              VerificationCodeInput(
                controller: pinController,
                focusNode: pinFocusNode,
                length: state.codeLength,
                hasError: state.hasCodeError,
                errorText: state.codeError,
                onChanged: cubit.codeChanged,
              ),

              SizedBox(height: 34.h),

              ResendCodeSection(
                remainingSeconds: state.remainingSeconds,
                canResend: state.canResend,
                isResending: state.isResending,
                onResendTap: cubit.resendCode,
              ),

              SizedBox(height: 24.h),

              VerifyEmailSubmitButton(
                canSubmit: state.canSubmit,
                isSubmitting: state.isSubmitting,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  cubit.submit();
                },
              ),

              SizedBox(height: 22.h),

              VerificationHelpLink(onTap: cubit.toggleHelp),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: state.isHelpVisible
                    ? Padding(
                        key: const ValueKey('verification-help-box'),
                        padding: EdgeInsets.only(top: 20.h),
                        child: const VerificationHelpBox(),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('verification-help-box-hidden'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
