import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:maan/core/design_system/app_theme_context.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsNoticeBox extends StatelessWidget {
  const TermsNoticeBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 61.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.colors.noticeBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.colors.noticeForeground.withValues(alpha: 0.35),
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: context.colors.noticeForeground,
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'terms_notice'.tr(),
              style: context.texts.f12W400SecColor,
            ),
          ),
        ],
      ),
    );
  }
}
