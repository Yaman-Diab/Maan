import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_validators.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';
import 'package:maan/core/design_system/widgets/password_text_form_field/password_text_form_field.dart';

import '../controller/login_controller.dart';
import '../models/login_payload.dart';
import 'auth_footer_sign_up.dart';
import 'forgot_password_button.dart';
import 'labeled_field.dart';
import 'login_header.dart';
import 'login_submit_button.dart';
import 'login_terms_agreement_field.dart';
import 'login_terms_notice_box.dart';
import 'or_divider.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onError,
    this.onForgotPasswordTap,
    this.onSignUpTap,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final LoginController controller;
  final Future<void> Function(LoginPayload payload) onSubmit;
  final void Function(String message) onError;
  final VoidCallback? onForgotPasswordTap;
  final VoidCallback? onSignUpTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Form(
            key: controller.formKey,
            autovalidateMode: controller.autovalidateMode,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LoginHeader(),

                  SizedBox(height: 88.h),

                  LabeledField(
                    label: 'Your Email',
                    child: CustomTextFormField(
                      controller: controller.emailController,
                      hintText: 'Enter your email address',
                      validationMessage: AppValidators.emailValidator,
                      keyBoardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  LabeledField(
                    label: 'Your Password',
                    child: PasswordTextFormField(
                      controller: controller.passwordController,
                      validationMessage: AppValidators.passwordValidator,
                      hintText: 'Enter your password',
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                    ),
                  ),

                  ForgotPasswordButton(onTap: onForgotPasswordTap),

                  SizedBox(height: 20.h),

                  const LoginTermsNoticeBox(),

                  SizedBox(height: 16.h),

                  LoginTermsAgreementField(
                    value: controller.isTermsAccepted,
                    onChanged: controller.setTermsAccepted,
                    onTermsTap: onTermsTap,
                    onPrivacyTap: onPrivacyTap,
                  ),

                  SizedBox(height: 24.h),

                  LoginSubmitButton(
                    canSubmit: controller.canSubmit,
                    isSubmitting: controller.isSubmitting,
                    onPressed: () {
                      FocusScope.of(context).unfocus();

                      controller.submit(
                        onSubmit: onSubmit,
                        onError: onError,
                      );
                    },
                  ),

                  SizedBox(height: 12.h),

                  const OrDivider(),

                  SizedBox(height: 8.h),

                  AuthFooterSignUp(onTap: onSignUpTap),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
