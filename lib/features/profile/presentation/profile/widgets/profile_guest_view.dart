// -------------------------
// Profile Guest View
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_button.dart';

/// اللي بيشوفه الزائر مطرح الملف الشخصي.
///
/// الزائر بلا حساب، فما في شي نجيبه. ضرب `/api/profile` بلا توكن بيرجّع
/// 401 و`AuthInterceptor` بيفهمها «انتهت الجلسة» فبيسجّل خروج — يعني
/// مجرد فتح التاب بيطلّع المستخدم. الحارس هون لا هناك.
class ProfileGuestView extends StatelessWidget {
  const ProfileGuestView({super.key, required this.onSignInTap});

  final VoidCallback onSignInTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final texts = context.texts;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 88.sp,
              color: colors.textSecondary,
            ),

            SizedBox(height: 20.h),

            Text(
              'profile_guest_title'.tr(),
              textAlign: TextAlign.center,
              style: texts.f16W500Black.copyWith(fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 8.h),

            Text(
              'profile_guest_message'.tr(),
              textAlign: TextAlign.center,
              style: texts.f14W400GreyColor,
            ),

            SizedBox(height: 28.h),

            AppButton(buttonText: 'sign_in'.tr(), buttonOnPressed: onSignInTap),
          ],
        ),
      ),
    );
  }
}
