import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_colors.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.borderColor,
            thickness: 1.h,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'or',
            style: AppTextStyles.f14W400HintColor,
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.borderColor,
            thickness: 1.h,
          ),
        ),
      ],
    );
  }
}
