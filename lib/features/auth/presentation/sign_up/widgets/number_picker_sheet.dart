import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

Future<int?> showNumberPickerSheet({
  required BuildContext context,
  required String title,
  required List<int> values,
  required int initialValue,
  String Function(int value)? labelBuilder,
}) {
  int initialIndex = values.indexOf(initialValue);

  if (initialIndex < 0) {
    initialIndex = 0;
  }

  int selectedValue = values[initialIndex];

  final scrollController = FixedExtentScrollController(
    initialItem: initialIndex,
  );

  final result = showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
    ),
    builder: (context) {
      return SafeArea(
        top: false,
        child: SizedBox(
          height: 320.h,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.f14W400HintColor,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.f16W500Black.copyWith(
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, selectedValue);
                      },
                      child: Text(
                        'Done',
                        style: AppTextStyles.f15W600Primary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1.h,
                thickness: 1.h,
                color: context.colors.border,
              ),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: scrollController,
                  itemExtent: 44.h,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    selectedValue = values[index];
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: values.length,
                    builder: (context, index) {
                      final value = values[index];

                      return Center(
                        child: Text(
                          labelBuilder?.call(value) ?? value.toString(),
                          style: AppTextStyles.f16W500Black.copyWith(
                            fontSize: 20.sp,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  return result.whenComplete(scrollController.dispose);
}
