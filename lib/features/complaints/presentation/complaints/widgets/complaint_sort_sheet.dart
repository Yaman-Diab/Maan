// -------------------------
// Complaint Sort Sheet
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../domain/entities/complaint_sort.dart';

Future<ComplaintSort?> showComplaintSortSheet(
  BuildContext context, {
  required ComplaintSort selected,
}) {
  return showModalBottomSheet<ComplaintSort>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _SortSheet(selected: selected),
  );
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.selected});

  final ComplaintSort selected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(22.r),
            topRight: Radius.circular(22.r),
          ),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'complaint_sort_sheet_title'.tr(),
              style: context.texts.f16W500Black.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4.h),
            for (final sort in ComplaintSort.values)
              InkWell(
                onTap: () => Navigator.of(context).pop(sort),
                child: SizedBox(
                  height: 52.h,
                  child: Row(
                    children: [
                      Icon(
                        sort == selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 22.sp,
                        color: sort == selected ? scheme.primary : colors.border,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        switch (sort) {
                          ComplaintSort.priority => 'complaint_sort_priority'.tr(),
                          ComplaintSort.newest => 'complaint_sort_newest'.tr(),
                          ComplaintSort.oldest => 'complaint_sort_oldest'.tr(),
                        },
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: sort == selected ? FontWeight.w600 : FontWeight.w400,
                          color: sort == selected ? scheme.primary : colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
