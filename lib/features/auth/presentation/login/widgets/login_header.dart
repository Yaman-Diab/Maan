import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('welcome_back'.tr(), style: context.texts.f32W600Black),
        SizedBox(height: 12.h),
        Text(
          'login_subtitle'.tr(),
          style: context.texts.f16W400Black.copyWith(fontSize: 16.sp),
        ),
      ],
    );
  }
}
