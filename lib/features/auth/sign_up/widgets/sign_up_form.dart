import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_validators.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';
import 'package:maan/core/design_system/widgets/password_text_form_field/password_text_form_field.dart';

import '../controller/sign_up_controller.dart';
import '../validators/sign_up_form_validators.dart';
import 'auth_footer_sign_in.dart';
import 'birthday_fields.dart';
import 'labeled_field.dart';
import 'or_divider.dart';
import '../../widget/password_rules_indicator.dart';
import 'sign_up_header.dart';
import 'sign_up_submit_button.dart';
import 'terms_agreement_field.dart';
import 'terms_notice_box.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.onSignInTap,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final SignUpController controller;
  final VoidCallback onSubmit;
  final VoidCallback? onSignInTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      autovalidateMode: controller.hasTriedSubmit
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SignUpHeader(),
            SizedBox(height: 28.h),
            Row(
              children: [
                Expanded(
                  child: LabeledField(
                    label: 'First name',
                    child: CustomTextFormField(
                      controller: controller.firstNameController,
                      hintText: 'Ahmad',
                      keyBoardType: TextInputType.name,
                      autofillHints: const [AutofillHints.givenName],
                      validationMessage: (value) {
                        return SignUpFormValidators.requiredName(
                          value,
                          'First name',
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: LabeledField(
                    label: 'Last name',
                    child: CustomTextFormField(
                      controller: controller.lastNameController,
                      hintText: 'Abo Hawa',
                      keyBoardType: TextInputType.name,
                      autofillHints: const [AutofillHints.familyName],
                      validationMessage: (value) {
                        return SignUpFormValidators.requiredName(
                          value,
                          'Last name',
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            BirthdayFields(controller: controller),
            SizedBox(height: 18.h),
            LabeledField(
              label: 'Your Email',
              child: CustomTextFormField(
                controller: controller.emailController,
                hintText: 'Enter your email address',
                keyBoardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validationMessage: AppValidators.emailValidator,
              ),
            ),
            SizedBox(height: 18.h),
            LabeledField(
              label: 'Your Password',
              child: PasswordTextFormField(
                controller: controller.passwordController,
                hintText: 'Enter your password',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validationMessage: AppValidators.passwordValidator,
              ),
            ),
            SizedBox(height: 10.h),
            PasswordRulesIndicator(controller: controller.passwordController),
            SizedBox(height: 18.h),
            LabeledField(
              label: 'Confirm Password',
              child: PasswordTextFormField(
                controller: controller.confirmPasswordController,
                hintText: 'Re-enter your password',
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validationMessage: (value) {
                  return AppValidators.confirmPasswordValidator(
                    value,
                    controller.passwordController.text,
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            const TermsNoticeBox(),
            SizedBox(height: 14.h),
            TermsAgreementField(
              value: controller.isTermsAccepted,
              onChanged: controller.setTermsAccepted,
              onTermsTap: onTermsTap,
              onPrivacyTap: onPrivacyTap,
            ),
            SizedBox(height: 18.h),
            SignUpSubmitButton(
              canSubmit: controller.canSubmit,
              isSubmitting: controller.isSubmitting,
              onPressed: onSubmit,
            ),
            SizedBox(height: 14.h),
            const OrDivider(),
            SizedBox(height: 8.h),
            AuthFooterSignIn(onSignInTap: onSignInTap),
          ],
        ),
      ),
    );
  }
}
