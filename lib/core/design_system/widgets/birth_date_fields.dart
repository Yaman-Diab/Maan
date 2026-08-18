import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';
import 'package:maan/core/design_system/birth_date_error_message.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';
import 'package:maan/core/design_system/widgets/number_picker_sheet.dart';
import 'package:maan/core/domain/birth_date.dart';

/// حقول تاريخ الميلاد الثلاثة — كلها read-only وبتتعبّى من pickers.
///
/// بتاخد الأجزاء الثلاثة كقيم بدل ما تاخد حالة شاشة معيّنة: شاشتان
/// بتستخدموها (التسجيل وتعديل الهوية) وحالاتهم أنواع مختلفة، فكانت
/// منسوخة مرتين. قيم العجلات بتنحسب من [BirthDate] مباشرة، وهي نفس
/// المصدر اللي بتفوّض له الحالتان أصلاً.
///
/// الـ controllers للعرض فقط؛ مصدر الحقيقة هو حالة الشاشة، فبنكتب
/// للاثنين بنفس اللحظة عبر [onDayPicked] وأخواتها.
class BirthDateFields extends StatelessWidget {
  const BirthDateFields({
    super.key,
    required this.label,
    required this.day,
    required this.month,
    required this.year,
    required this.dayController,
    required this.monthController,
    required this.yearController,
    required this.onDayPicked,
    required this.onMonthPicked,
    required this.onYearPicked,
    this.error,
    this.labelStyle,
    this.labelGap = 10,
    this.enabled = true,
  });

  final String label;
  final TextStyle? labelStyle;

  /// المسافة بين العنوان والحقول، بوحدات `ScreenUtil`.
  final double labelGap;

  final int? day;
  final int? month;
  final int? year;

  final BirthDateError? error;

  final TextEditingController dayController;
  final TextEditingController monthController;
  final TextEditingController yearController;

  final ValueChanged<int> onDayPicked;
  final ValueChanged<int> onMonthPicked;
  final ValueChanged<int> onYearPicked;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final borderColor = error != null
        ? context.scheme.error
        : context.colors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              labelStyle ??
              context.texts.f16W500Black.copyWith(fontSize: 16.sp),
        ),
        SizedBox(height: labelGap.h),
        Row(
          children: [
            Expanded(
              child: _PickerField(
                controller: dayController,
                hintText: 'day_hint'.tr(),
                borderColor: borderColor,
                enabled: enabled,
                onTap: () => _pickDay(context),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _PickerField(
                controller: monthController,
                hintText: 'month_hint'.tr(),
                borderColor: borderColor,
                enabled: enabled,
                onTap: () => _pickMonth(context),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _PickerField(
                controller: yearController,
                hintText: 'year_hint'.tr(),
                borderColor: borderColor,
                enabled: enabled,
                onTap: () => _pickYear(context),
              ),
            ),
          ],
        ),
        if (error != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Text(
              error!.message,
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
      title: 'select_day'.tr(),
      values: List.generate(
        BirthDate.maxSelectableDay(month: month, year: year),
        (index) => index + 1,
      ),
      initialValue: BirthDate.initialDay(day: day, month: month, year: year),
      labelBuilder: _padded,
    );

    if (selected == null) return;

    onDayPicked(selected);
  }

  Future<void> _pickMonth(BuildContext context) async {
    final selected = await showNumberPickerSheet(
      context: context,
      title: 'select_month'.tr(),
      values: List.generate(12, (index) => index + 1),
      initialValue: BirthDate.initialMonth(month),
      labelBuilder: _padded,
    );

    if (selected == null) return;

    onMonthPicked(selected);
  }

  Future<void> _pickYear(BuildContext context) async {
    final selected = await showNumberPickerSheet(
      context: context,
      title: 'select_year'.tr(),
      values: BirthDate.selectableYears(),
      initialValue: BirthDate.initialYear(year),
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
    required this.enabled,
    required this.onTap,
  });

  final TextEditingController controller;
  final String hintText;
  final Color borderColor;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: controller,
      hintText: hintText,
      keyBoardType: TextInputType.none,
      readOnly: true,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      enabledBorderColor: borderColor,
      // التاريخ بينتحقق كقيمة وحدة بالـ Cubit عبر
      // BirthDate.validateParts، فما بدنا ثلاث رسائل مكررة تحت الحقول.
      validationMessage: null,
      suffixIcon: enabled
          ? Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp)
          : null,
    );
  }
}
