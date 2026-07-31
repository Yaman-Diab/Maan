import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_validators.dart';
import 'package:maan/core/design_system/app_theme_context.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';
import 'package:maan/core/design_system/widgets/labeled_field.dart';
import 'package:maan/core/design_system/widgets/or_divider.dart';
import 'package:maan/core/design_system/widgets/password_text_form_field/password_text_form_field.dart';

import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import 'auth_footer_sign_up.dart';
import 'forgot_password_button.dart';
import 'login_header.dart';
import 'login_submit_button.dart';
import '../../shared/widgets/terms_agreement_field.dart';
import 'login_terms_notice_box.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.state,
    this.onForgotPasswordTap,
    this.onSignUpTap,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  /// دورة حياة الـ controllers والـ formKey مسؤولية `LoginPage`،
  /// والـ Cubit بيحمل القيم كنصوص فقط.
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final LoginState state;

  final VoidCallback? onForgotPasswordTap;
  final VoidCallback? onSignUpTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.texts.f16W500Black.copyWith(fontSize: 16.sp);
    final cubit = context.read<LoginCubit>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Form(
            key: formKey,
            autovalidateMode: state.hasTriedSubmit
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LoginHeader(),

                  SizedBox(height: 88.h),

                  LabeledField(
                    label: 'your_email'.tr(),
                    labelStyle: labelStyle,
                    gap: 12,
                    child: CustomTextFormField(
                      controller: emailController,
                      hintText: 'enter_email'.tr(),
                      validationMessage: AppValidators.emailValidator,
                      keyBoardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      onChanged: cubit.emailChanged,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  LabeledField(
                    label: 'your_password'.tr(),
                    labelStyle: labelStyle,
                    gap: 12,
                    child: PasswordTextFormField(
                      controller: passwordController,
                      validationMessage: AppValidators.loginPasswordValidator,
                      hintText: 'enter_password'.tr(),
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onChanged: cubit.passwordChanged,
                    ),
                  ),

                  ForgotPasswordButton(onTap: onForgotPasswordTap),

                  SizedBox(height: 20.h),

                  const LoginTermsNoticeBox(),

                  SizedBox(height: 16.h),

                  TermsAgreementField(
                    textTopPadding: 2,
                    value: state.isTermsAccepted,
                    onChanged: cubit.termsToggled,
                    onTermsTap: onTermsTap,
                    onPrivacyTap: onPrivacyTap,
                  ),

                  SizedBox(height: 24.h),

                  LoginSubmitButton(
                    canSubmit: state.canSubmit,
                    isSubmitting: state.isSubmitting,
                    onPressed: () {
                      FocusScope.of(context).unfocus();

                      cubit.submit(
                        isFormValid: () =>
                            formKey.currentState?.validate() ?? false,
                      );
                    },
                  ),

                  SizedBox(height: 12.h),

                  OrDivider(color: context.colors.divider),

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
