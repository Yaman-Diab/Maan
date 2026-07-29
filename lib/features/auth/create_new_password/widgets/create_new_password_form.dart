import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_validators.dart';
import 'package:maan/core/design_system/widgets/password_text_form_field/password_text_form_field.dart';
import 'package:maan/features/auth/widget/password_rules_indicator.dart';

import '../controller/create_new_password_controller.dart';
import 'create_new_password_header.dart';
import 'create_new_password_submit_button.dart';
import 'labeled_field.dart';

class CreateNewPasswordForm extends StatelessWidget {
  const CreateNewPasswordForm({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  final CreateNewPasswordController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      autovalidateMode: controller.autovalidateMode,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CreateNewPasswordHeader(),

            SizedBox(height: 40.h),

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

            SizedBox(height: 12.h),

            PasswordRulesIndicator(
              controller: controller.passwordController,
              layout: PasswordRulesLayout.vertical,
            ),

            const Spacer(),

            CreateNewPasswordSubmitButton(
              canSubmit: controller.canSubmit,
              isSubmitting: controller.isSubmitting,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
