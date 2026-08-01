// -------------------------
// Profile Section Header
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';

/// عنوان قسم، مع إجراء اختياري بالطرف الثاني.
class ProfileSectionHeader extends StatelessWidget {
  const ProfileSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.texts.f14W600Black.copyWith(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // الاثنان مرنان: مع تكبير الخط لازم ينكمشوا سوا بدل ما يزيح
        // أحدهما الثاني برّا الشاشة.
        if (trailing != null) ...[
          SizedBox(width: 12.w),
          Flexible(child: trailing!),
        ],
      ],
    );
  }
}
