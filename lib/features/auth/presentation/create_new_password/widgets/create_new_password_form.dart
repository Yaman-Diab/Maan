import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_validators.dart';
import 'package:maan/core/design_system/widgets/labeled_field.dart';
import 'package:maan/core/design_system/widgets/password_text_form_field/password_text_form_field.dart';

import '../../shared/widgets/password_rules_indicator.dart';
import '../cubit/create_new_password_cubit.dart';
import '../cubit/create_new_password_state.dart';
import 'create_new_password_header.dart';
import 'create_new_password_submit_button.dart';

class CreateNewPasswordForm extends StatelessWidget {
  const CreateNewPasswordForm({
    super.key,
    required this.formKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.state,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final CreateNewPasswordState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateNewPasswordCubit>();

    return Form(
      key: formKey,
      autovalidateMode: state.hasTriedSubmit
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CreateNewPasswordHeader(),

            SizedBox(height: 40.h),

            LabeledField(
              label: 'your_password'.tr(),
              child: PasswordTextFormField(
                controller: passwordController,
                hintText: 'enter_password'.tr(),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: cubit.passwordChanged,
                validationMessage: AppValidators.passwordValidator,
              ),
            ),

            SizedBox(height: 18.h),

            LabeledField(
              label: 'confirm_password'.tr(),
              child: PasswordTextFormField(
                controller: confirmPasswordController,
                hintText: 'enter_confirm_password'.tr(),
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: cubit.confirmPasswordChanged,
                validationMessage: (value) =>
                    AppValidators.confirmPasswordValidator(
                      value,
                      state.password,
                    ),
              ),
            ),

            SizedBox(height: 12.h),

            PasswordRulesIndicator(
              checks: state.passwordChecks,
              layout: PasswordRulesLayout.vertical,
            ),

            const Spacer(),

            CreateNewPasswordSubmitButton(
              canSubmit: state.canSubmit,
              isSubmitting: state.isSubmitting,
              onPressed: () {
                FocusScope.of(context).unfocus();

                cubit.submit(
                  isFormValid: () => formKey.currentState?.validate() ?? false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
