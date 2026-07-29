import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_colors.dart';
import 'package:maan/core/design_system/app_text_styles.dart';
import 'package:maan/core/design_system/app_validators.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';
import 'package:maan/core/design_system/widgets/labeled_field.dart';

import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import 'forgot_password_header.dart';
import 'forgot_password_submit_button.dart';

class ForgotPasswordForm extends StatelessWidget {
  const ForgotPasswordForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.state,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final ForgotPasswordState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ForgotPasswordCubit>();

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
                    key: formKey,
                    autovalidateMode: state.hasTriedSubmit
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ForgotPasswordHeader(),

                          SizedBox(height: 56.h),

                          LabeledField(
                            label: 'Your Email',
                            labelStyle: AppTextStyles.f16W500Black.copyWith(
                              fontSize: 14.sp,
                            ),
                            child: CustomTextFormField(
                              controller: emailController,
                              hintText: 'Enter your email address',
                              validationMessage: AppValidators.emailValidator,
                              keyBoardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.email],
                              onChanged: cubit.emailChanged,
                            ),
                          ),

                          const Spacer(),

                          ForgotPasswordSubmitButton(
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
