// -------------------------
// Settings Confirm Sheet
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/design_system/app_theme_context.dart';
import '../../../../core/design_system/widgets/app_button.dart';

/// ورقة تأكيد مشتركة — تسجيل الخروج وحذف الحساب نفس الشكل، لون الزر
/// وحده الفرق. بترجّع `true` بس لو ضغط زر التأكيد؛ أي طريقة خروج تانية
/// (نقرة برّا، سحب، إلغاء) بترجّع `false` — عكس عجلة الاختيار، هون
/// «الخروج بلا زر» قرار واضح: ما أكّد.
Future<bool> showSettingsConfirmSheet({
  required BuildContext context,
  required String title,
  required String body,
  required String confirmLabel,
  required Color confirmColor,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: context.scheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: sheetContext.texts.f16W500Black.copyWith(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                body,
                style: sheetContext.texts.f12W400SecColor.copyWith(
                  fontSize: 13.sp,
                  height: 1.6,
                  color: sheetContext.colors.textSecondary,
                ),
              ),
              SizedBox(height: 22.h),
              AppButton(
                buttonText: confirmLabel,
                buttonColor: confirmColor,
                buttonColorSide: confirmColor,
                buttonOnPressed: () => Navigator.of(sheetContext).pop(true),
              ),
              SizedBox(height: 14.h),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: Text(
                    'cancel'.tr(),
                    style: sheetContext.texts.f14W400HintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  return confirmed ?? false;
}
