import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';

import '../birth_date_error_message.dart';
import '../cubit/sign_up_state.dart';
import 'number_picker_sheet.dart';

/// حقول تاريخ الميلاد الثلاثة — كلها read-only وبتتعبّى من pickers.
///
/// الـ controllers للعرض فقط؛ مصدر الحقيقة هو [SignUpState]، فبنكتب
/// للاثنين بنفس اللحظة عبر [onDayPicked] وأخواتها.
class BirthdayFields extends StatelessWidget {
  const BirthdayFields({
    super.key,
    required this.state,
    required this.dayController,
    required this.monthController,
    required this.yearController,
    required this.onDayPicked,
    required this.onMonthPicked,
    required this.onYearPicked,
  });

  final SignUpState state;
  final TextEditingController dayController;
  final TextEditingController monthController;
  final TextEditingController yearController;
  final ValueChanged<int> onDayPicked;
  final ValueChanged<int> onMonthPicked;
  final ValueChanged<int> onYearPicked;

  @override
  Widget build(BuildContext context) {
    final borderColor = state.hasBirthDateError
        ? context.scheme.error
        : context.colors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your birthday',
          style: context.texts.f16W500Black.copyWith(fontSize: 16.sp),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _PickerField(
                controller: dayController,
                hintText: 'Day',
                borderColor: borderColor,
                onTap: () => _pickDay(context),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _PickerField(
                controller: monthController,
                hintText: 'Month',
                borderColor: borderColor,
                onTap: () => _pickMonth(context),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _PickerField(
                controller: yearController,
                hintText: 'Year',
                borderColor: borderColor,
                onTap: () => _pickYear(context),
              ),
            ),
          ],
        ),
        if (state.birthDateError != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Text(
              state.birthDateError!.message,
              style: TextStyle(
                color: context.scheme.error,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickDay(BuildContext context) async {
    final selected = await showNumberPickerSheet(
      context: context,
      title: 'Select Day',
      values: List.generate(
        state.maxDayForSelectedMonthYear,
        (index) => index + 1,
      ),
      initialValue: state.initialDay,
      labelBuilder: _padded,
    );

    if (selected == null) return;

    onDayPicked(selected);
  }

  Future<void> _pickMonth(BuildContext context) async {
    final selected = await showNumberPickerSheet(
      context: context,
      title: 'Select Month',
      values: List.generate(12, (index) => index + 1),
      initialValue: state.initialMonth,
      labelBuilder: _padded,
    );

    if (selected == null) return;

    onMonthPicked(selected);
  }

  Future<void> _pickYear(BuildContext context) async {
    final selected = await showNumberPickerSheet(
      context: context,
      title: 'Select Year',
      values: state.yearValues,
      initialValue: state.initialYear,
    );

    if (selected == null) return;

    onYearPicked(selected);
  }

  static String _padded(int value) => value.toString().padLeft(2, '0');
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.controller,
    required this.hintText,
    required this.borderColor,
    required this.onTap,
  });

  final TextEditingController controller;
  final String hintText;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: controller,
      hintText: hintText,
      keyBoardType: TextInputType.none,
      readOnly: true,
      onTap: onTap,
      enabledBorderColor: borderColor,
      // التاريخ بينتحقق كقيمة وحدة بالـ Cubit عبر
      // BirthDate.validateParts، فما بدنا ثلاث رسائل مكررة تحت الحقول.
      validationMessage: null,
      suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp),
    );
  }
}
