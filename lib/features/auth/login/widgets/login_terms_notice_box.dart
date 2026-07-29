import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

class LoginTermsNoticeBox extends StatelessWidget {
  const LoginTermsNoticeBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 61.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF5E7),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFC47E09).withOpacity(0.25),
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFFC47E09),
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Please read the Terms of Use and Privacy Policy. They explain your responsibilities and the actions that may be taken in case of violations.',
              style: AppTextStyles.f12W400SecColor,
            ),
          ),
        ],
      ),
    );
  }
}
