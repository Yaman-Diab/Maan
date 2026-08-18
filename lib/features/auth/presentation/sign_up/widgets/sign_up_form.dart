import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';
import 'package:maan/core/design_system/app_validators.dart';
import 'package:maan/core/design_system/widgets/birth_date_fields.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';
import 'package:maan/core/design_system/widgets/labeled_field.dart';
import 'package:maan/core/design_system/widgets/or_divider.dart';
import 'package:maan/core/design_system/widgets/password_text_form_field/password_text_form_field.dart';

import '../../shared/widgets/password_rules_indicator.dart';
import '../cubit/sign_up_cubit.dart';
import '../cubit/sign_up_state.dart';
import 'auth_footer_sign_in.dart';

import 'sign_up_header.dart';
import 'sign_up_submit_button.dart';
import '../../shared/widgets/terms_agreement_field.dart';
import 'terms_notice_box.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    required this.state,
    required this.controllers,
    required this.onSubmit,
    this.onSignInTap,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final GlobalKey<FormState> formKey;
  final SignUpState state;
  final SignUpFieldControllers controllers;
  final VoidCallback onSubmit;
  final VoidCallback? onSignInTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.texts.f16W500Black.copyWith(fontSize: 16.sp);
    final cubit = context.read<SignUpCubit>();

    return Form(
      key: formKey,
      autovalidateMode: state.hasTriedSubmit
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
                    label: 'first_name'.tr(),
                    labelStyle: labelStyle,
                    child: CustomTextFormField(
                      controller: controllers.firstName,
                      hintText: 'first_name_hint'.tr(),
                      keyBoardType: TextInputType.name,
                      autofillHints: const [AutofillHints.givenName],
                      maxLength: AppValidators.nameMaxLength,
                      onChanged: cubit.firstNameChanged,
                      validationMessage: (value) =>
                          AppValidators.requiredName(value, 'first_name'.tr()),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: LabeledField(
                    label: 'last_name'.tr(),
                    labelStyle: labelStyle,
                    child: CustomTextFormField(
                      controller: controllers.lastName,
                      hintText: 'last_name_hint'.tr(),
                      keyBoardType: TextInputType.name,
                      autofillHints: const [AutofillHints.familyName],
                      maxLength: AppValidators.nameMaxLength,
                      onChanged: cubit.lastNameChanged,
                      validationMessage: (value) =>
                          AppValidators.requiredName(value, 'last_name'.tr()),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            BirthDateFields(
              label: 'your_birthday'.tr(),
              day: state.day,
              month: state.month,
              year: state.year,
              error: state.birthDateError,
              dayController: controllers.day,
              monthController: controllers.month,
              yearController: controllers.year,
              onDayPicked: (value) {
                controllers.setDay(value);
                cubit.dayChanged(value);
              },
              onMonthPicked: (value) {
                cubit.monthChanged(value);
                controllers.setMonth(value);
                controllers.syncDay(cubit.state.day);
              },
              onYearPicked: (value) {
                cubit.yearChanged(value);
                controllers.setYear(value);
                controllers.syncDay(cubit.state.day);
              },
            ),
            SizedBox(height: 18.h),
            LabeledField(
              label: 'your_email'.tr(),
              labelStyle: labelStyle,
              child: CustomTextFormField(
                controller: controllers.email,
                hintText: 'enter_email'.tr(),
                keyBoardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                maxLength: AppValidators.emailMaxLength,
                onChanged: cubit.emailChanged,
                validationMessage: AppValidators.emailValidator,
              ),
            ),
            SizedBox(height: 18.h),
            LabeledField(
              label: 'your_password'.tr(),
              labelStyle: labelStyle,
              child: PasswordTextFormField(
                controller: controllers.password,
                hintText: 'enter_password'.tr(),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                maxLength: AppValidators.passwordMaxLength,
                onChanged: cubit.passwordChanged,
                validationMessage: AppValidators.passwordValidator,
              ),
            ),
            SizedBox(height: 10.h),
            PasswordRulesIndicator(checks: state.passwordChecks),
            SizedBox(height: 18.h),
            LabeledField(
              label: 'confirm_password'.tr(),
              labelStyle: labelStyle,
              child: PasswordTextFormField(
                controller: controllers.confirmPassword,
                hintText: 'enter_confirm_password'.tr(),
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                maxLength: AppValidators.passwordMaxLength,
                onChanged: cubit.confirmPasswordChanged,
                validationMessage: (value) =>
                    AppValidators.confirmPasswordValidator(
                      value,
                      state.password,
                    ),
              ),
            ),
            SizedBox(height: 20.h),
            const TermsNoticeBox(),
            SizedBox(height: 14.h),
            TermsAgreementField(
              value: state.isTermsAccepted,
              onChanged: cubit.termsToggled,
              onTermsTap: onTermsTap,
              onPrivacyTap: onPrivacyTap,
            ),
            SizedBox(height: 18.h),
            SignUpSubmitButton(
              canSubmit: state.canSubmit,
              isSubmitting: state.isSubmitting,
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

/// حاوية الـ controllers تبع الشاشة.
///
/// موجودة حتى ما تتحوّل `SignUpForm` لثمانية باراميترات؛ دورة حياتها
/// مسؤولية `_SignUpPageState`.
class SignUpFieldControllers {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final day = TextEditingController();
  final month = TextEditingController();
  final year = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  void setDay(int value) => day.text = value.toString().padLeft(2, '0');

  void setMonth(int value) => month.text = value.toString().padLeft(2, '0');

  void setYear(int value) => year.text = value.toString();

  /// بعد تغيير الشهر أو السنة ممكن الـ Cubit يقصّ اليوم، فبنعكس القيمة
  /// المقصوصة على الحقل.
  void syncDay(int? value) {
    if (value == null) return;

    setDay(value);
  }

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    day.dispose();
    month.dispose();
    year.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
  }
}
