// -------------------------
// Profile Error View
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_button.dart';

class ProfileErrorView extends StatelessWidget {
  const ProfileErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  /// جاهزة للعرض — مصدرها `Failure.message` اللي بيبنيها
  /// `ApiErrorMessages`، فبتتبع لغة التطبيق.
  final String message;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final texts = context.texts;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 72.sp,
              color: context.colors.textSecondary,
            ),

            SizedBox(height: 20.h),

            Text(
              message,
              textAlign: TextAlign.center,
              style: texts.f14W400GreyColor,
            ),

            SizedBox(height: 28.h),

            AppButton(buttonText: 'retry'.tr(), buttonOnPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
