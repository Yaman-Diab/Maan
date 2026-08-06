// -------------------------
// Activity Card
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_card.dart';
import 'profile_icon_chip.dart';

/// بطاقة نشاط: أيقونة + عنوان + عدّاد.
///
/// [countLabel] بتقبل `null` — ما في endpoint بيرجّع العدّادات بعد،
/// فبتعرض «—» بدل صفر يوهم إن المستخدم ما شارك بشي.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.title,
    required this.countLabel,
    required this.icon,
    required this.iconForeground,
    required this.iconBackground,
  });

  final String title;
  final String? countLabel;
  final IconData icon;
  final Color iconForeground;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final texts = context.texts;

    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileIconChip(
            icon: icon,
            foreground: iconForeground,
            background: iconBackground,
            boxSize: 36,
            iconSize: 21,
            radius: 10,
          ),

          SizedBox(height: 9.h),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: texts.f14W600Black.copyWith(fontSize: 11.5.sp),
          ),

          SizedBox(height: 3.h),

          Text(
            countLabel ?? '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: texts.f12W400SecColor.copyWith(
              fontSize: 10.sp,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
