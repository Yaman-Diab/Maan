import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

class CreateNewPasswordHeader extends StatelessWidget {
  const CreateNewPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'create_new_password_title'.tr(),
          style: context.texts.f32W600Black.copyWith(fontSize: 24.sp),
        ),
        SizedBox(height: 12.h),
        Text(
          'create_new_password_subtitle'.tr(),
          style: context.texts.f14W400GreyColor,
        ),
      ],
    );
  }
}
