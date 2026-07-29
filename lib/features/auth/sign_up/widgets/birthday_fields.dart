import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_colors.dart';
import 'package:maan/core/design_system/app_text_styles.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';

import '../controller/sign_up_controller.dart';
import '../validators/sign_up_form_validators.dart';
import 'number_picker_sheet.dart';

class BirthdayFields extends StatelessWidget {
  const BirthdayFields({
    super.key,
    required this.controller,
  });

  final SignUpController controller;

  @override
  Widget build(BuildContext context) {
    final borderColor = controller.hasBirthdayError
        ? AppColors.errorColor
        : AppColors.borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your birthday',
          style: AppTextStyles.f16W500Black.copyWith(fontSize: 16.sp),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: controller.dayController,
                hintText: 'Day',
                keyBoardType: TextInputType.none,
                readOnly: true,
                onTap: () => _pickDay(context),
                enabledBorderColor: borderColor,
                validationMessage: SignUpFormValidators.dateField,
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: CustomTextFormField(
                controller: controller.monthController,
                hintText: 'Month',
                keyBoardType: TextInputType.none,
                readOnly: true,
                onTap: () => _pickMonth(context),
                enabledBorderColor: borderColor,
                validationMessage: SignUpFormValidators.dateField,
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: CustomTextFormField(
                controller: controller.yearController,
                hintText: 'Year',
                keyBoardType: TextInputType.none,
                readOnly: true,
                onTap: () => _pickYear(context),
                enabledBorderColor: borderColor,
                validationMessage: SignUpFormValidators.dateField,
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
        if (controller.birthdayError != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Text(
              controller.birthdayError!,
              style: TextStyle(
                color: AppColors.errorColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickDay(BuildContext context) async {
    final maxDay = controller.maxDayForSelectedMonthYear;

    final selectedDay = await showNumberPickerSheet(
      context: context,
      title: 'Select Day',
      values: List.generate(maxDay, (index) => index + 1),
      initialValue: controller.initialDay,
      labelBuilder: (value) => value.toString().padLeft(2, '0'),
    );

    if (selectedDay == null) return;

    controller.setDay(selectedDay);
  }

  Future<void> _pickMonth(BuildContext context) async {
    final selectedMonth = await showNumberPickerSheet(
      context: context,
      title: 'Select Month',
      values: List.generate(12, (index) => index + 1),
      initialValue: controller.initialMonth,
      labelBuilder: (value) => value.toString().padLeft(2, '0'),
    );

    if (selectedMonth == null) return;

    controller.setMonth(selectedMonth);
  }

  Future<void> _pickYear(BuildContext context) async {
    final selectedYear = await showNumberPickerSheet(
      context: context,
      title: 'Select Year',
      values: controller.yearValues,
      initialValue: controller.initialYear,
    );

    if (selectedYear == null) return;

    controller.setYear(selectedYear);
  }
}
