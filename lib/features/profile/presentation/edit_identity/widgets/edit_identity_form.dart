// -------------------------
// Edit Identity Form
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';
import 'package:maan/core/design_system/app_validators.dart';
import 'package:maan/core/design_system/widgets/birth_date_fields.dart';
import 'package:maan/core/design_system/widgets/app_submit_button.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';
import 'package:maan/core/design_system/widgets/labeled_field.dart';

import '../../profile/widgets/profile_card.dart';
import '../cubit/edit_identity_cubit.dart';
import '../cubit/edit_identity_state.dart';

import 'edit_identity_notice.dart';

class EditIdentityForm extends StatelessWidget {
  const EditIdentityForm({
    super.key,
    required this.formKey,
    required this.state,
    required this.controllers,
    required this.onSave,
    required this.onCancel,
  });

  final GlobalKey<FormState> formKey;
  final EditIdentityState state;
  final EditIdentityFieldControllers controllers;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditIdentityCubit>();
    final labelStyle = context.texts.f14W400HintColor.copyWith(
      fontSize: 13.sp,
      color: context.colors.textSecondary,
    );

    return Scaffold(
      backgroundColor: context.colors.pageBackground,
      appBar: AppBar(
        backgroundColor: context.colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'edit_identity_title'.tr(),
          style: context.texts.f16W500Black.copyWith(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          autovalidateMode: state.hasTriedSubmit
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileCard(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 22.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LabeledField(
                              label: 'first_name'.tr(),
                              labelStyle: labelStyle,
                              child: CustomTextFormField(
                                controller: controllers.firstName,
                                keyBoardType: TextInputType.name,
                                enabled: !state.isLocked,
                                maxLength: AppValidators.nameMaxLength,
                                onChanged: cubit.firstNameChanged,
                                validationMessage: (value) =>
                                    AppValidators.requiredName(
                                      value,
                                      'first_name'.tr(),
                                    ),
                              ),
                            ),
                            SizedBox(height: 18.h),
                            LabeledField(
                              label: 'last_name'.tr(),
                              labelStyle: labelStyle,
                              child: CustomTextFormField(
                                controller: controllers.lastName,
                                keyBoardType: TextInputType.name,
                                enabled: !state.isLocked,
                                maxLength: AppValidators.nameMaxLength,
                                onChanged: cubit.lastNameChanged,
                                validationMessage: (value) =>
                                    AppValidators.requiredName(
                                      value,
                                      'last_name'.tr(),
                                    ),
                              ),
                            ),
                            SizedBox(height: 18.h),
                            LabeledField(
                              label: 'national_id'.tr(),
                              labelStyle: labelStyle,
                              child: CustomTextFormField(
                                controller: controllers.nationalId,
                                keyBoardType: TextInputType.number,
                                digitsOnly: true,
                                enabled: !state.isLocked,
                                maxLength:
                                    AppValidators.nationalIdMaxLength,
                                onChanged: cubit.nationalIdChanged,
                                validationMessage:
                                    AppValidators.requiredNationalId,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 6.h, left: 4.w),
                              child: Text(
                                'edit_identity_national_id_helper'.tr(),
                                style: context.texts.f12W400SecColor,
                              ),
                            ),
                            SizedBox(height: 18.h),
                            BirthDateFields(
                              label: 'date_of_birth'.tr(),
                              labelStyle: labelStyle,
                              labelGap: 8,
                              enabled: !state.isLocked,
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
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      EditIdentityNotice(isLocked: state.isLocked),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
                child: Column(
                  children: [
                    if (!state.isLocked)
                      AppSubmitButton(
                        canSubmit: state.canSubmit,
                        isSubmitting: state.isSubmitting,
                        label: 'save_changes'.tr(),
                        submittingLabel: 'saving'.tr(),
                        onPressed: onSave,
                      ),
                    SizedBox(height: 14.h),
                    GestureDetector(
                      onTap: onCancel,
                      child: Text(
                        'cancel'.tr(),
                        style: context.texts.f14W400HintColor.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// حاوية الـ controllers — نفس نمط `SignUpFieldControllers`.
class EditIdentityFieldControllers {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final nationalId = TextEditingController();
  final day = TextEditingController();
  final month = TextEditingController();
  final year = TextEditingController();

  EditIdentityFieldControllers({
    required String firstName,
    required String lastName,
    required String nationalId,
    int? day,
    int? month,
    int? year,
  }) {
    this.firstName.text = firstName;
    this.lastName.text = lastName;
    this.nationalId.text = nationalId;

    if (day != null) setDay(day);
    if (month != null) setMonth(month);
    if (year != null) setYear(year);
  }

  void setDay(int value) => day.text = value.toString().padLeft(2, '0');

  void setMonth(int value) => month.text = value.toString().padLeft(2, '0');

  void setYear(int value) => year.text = value.toString();

  void syncDay(int? value) {
    if (value == null) return;

    setDay(value);
  }

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    nationalId.dispose();
    day.dispose();
    month.dispose();
    year.dispose();
  }
}
