// -------------------------
// Home Section Header
// -------------------------

import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';

/// عنوان قسم بالرئيسية + رابط «عرض الكل» اختياري.
///
/// منفصل عن `AppSectionHeader` بـ`core`: هداك عنوان بحت بلا إجراء،
/// وهاد صف عنوان+رابط. الفرق حقيقي مش تجميلي.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({super.key, required this.title, this.onViewAll});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.f14W600Black.copyWith(fontSize: 14.5.sp),
          ),
        ),
        if (onViewAll != null)
          InkWell(
            onTap: onViewAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'home_view_all'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: scheme.primary,
                  ),
                ),
                Icon(
                  isRtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  size: 18.sp,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
