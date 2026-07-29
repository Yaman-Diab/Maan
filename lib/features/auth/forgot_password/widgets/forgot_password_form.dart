import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_colors.dart';
import 'package:maan/core/design_system/app_validators.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';

import '../controller/forgot_password_controller.dart';
import '../models/forgot_password_payload.dart';
import 'forgot_password_header.dart';
import 'forgot_password_submit_button.dart';
import 'labeled_field.dart';

class ForgotPasswordForm extends StatelessWidget {
  const ForgotPasswordForm({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onError,
  });

  final ForgotPasswordController controller;
  final Future<void> Function(ForgotPasswordPayload payload) onSubmit;
  final void Function(String message) onError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 36.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 72.h,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: controller.formKey,
                    autovalidateMode: controller.autovalidateMode,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ForgotPasswordHeader(),

                          SizedBox(height: 56.h),

                          LabeledField(
                            label: 'Your Email',
                            child: CustomTextFormField(
                              controller: controller.emailController,
                              hintText: 'Enter your email address',
                              validationMessage: AppValidators.emailValidator,
                              keyBoardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.email],
                            ),
                          ),

                          const Spacer(),

                          ForgotPasswordSubmitButton(
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
