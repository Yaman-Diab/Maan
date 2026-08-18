// -------------------------
// Donate Dialog
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../domain/entities/municipal_project.dart';

/// حوار **معلوماتي بحت** — بلا أي حقل إدخال وبلا أي مبلغ.
///
/// ⚠️ التبرع ما بيصير عبر التطبيق إطلاقاً (قرار صريح من صاحب المشروع):
/// المواطن لازم يزور البلدية شخصياً مع بطاقة هويته، لأن التبرع بينربط
/// برقمه الوطني هناك. فزر «تبرّع» بالبطاقة بيفتح هالتوجيه بس — مش
/// بداية عملية دفع.
Future<void> showDonateDialog(
  BuildContext context, {
  required MunicipalProject project,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: context.scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      contentPadding: EdgeInsets.all(20.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: context.colors.noticeBackground,
                  borderRadius: BorderRadius.circular(AppRadius.md.r),
                ),
                child: Icon(
                  Icons.savings_rounded,
                  size: 21.sp,
                  color: context.colors.noticeForeground,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'donate_dialog_title'.tr(
                    namedArgs: {'project': project.title},
                  ),
                  style: context.texts.f16W500Black.copyWith(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            'donate_dialog_body'.tr(),
            style: context.texts.f14W400HintColor.copyWith(
              color: context.colors.textSecondary,
              height: 1.55,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md.r),
                ),
              ),
              child: Text('donate_dialog_close'.tr()),
            ),
          ),
        ],
      ),
    ),
  );
}
