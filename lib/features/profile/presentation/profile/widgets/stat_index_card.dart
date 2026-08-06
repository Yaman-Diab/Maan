// -------------------------
// Stat Index Card
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../domain/entities/profile_stats.dart';
import '../../../../../core/design_system/widgets/app_card.dart';
import 'profile_icon_chip.dart';

/// بطاقة مؤشّر بنسبة مئوية وشريط تقدّم.
///
/// [percentage] بتقبل `null` لأن الباك اند لسه ما بيرجّع المؤشرات —
/// وقتها بتعرض «—» وشريط فاضي بدل رقم مخترع. راجع [ProfileStats].
class StatIndexCard extends StatelessWidget {
  const StatIndexCard({
    super.key,
    required this.label,
    required this.icon,
    required this.iconForeground,
    required this.iconBackground,
    required this.percentage,
  });

  final String label;
  final IconData icon;
  final Color iconForeground;
  final Color iconBackground;
  final int? percentage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final texts = context.texts;
    final scheme = context.scheme;

    return AppCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileIconChip(
                icon: icon,
                foreground: iconForeground,
                background: iconBackground,
                boxSize: 32,
                iconSize: 19,
                radius: 8,
              ),

              SizedBox(width: 8.w),

              Expanded(
                child: Text(
                  label,
                  // `end` لا `right`: بتنعكس لليسار بالعربي لحالها.
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: texts.f12W400SecColor.copyWith(
                    fontSize: 10.sp,
                    height: 1.3,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                percentage == null ? '—' : '$percentage%',
                style: texts.f16W500Black.copyWith(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: scheme.primary,
                ),
              ),

              SizedBox(width: 6.w),

              Expanded(
                child: Text(
                  _levelLabel,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: texts.f12W400SecColor.copyWith(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.success,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          _ProgressBar(percentage: percentage),
        ],
      ),
    );
  }

  String get _levelLabel {
    final value = percentage;
    if (value == null) return '';

    return switch (ProfileStats.levelOf(value)) {
      StatLevel.beginner => 'level_beginner'.tr(),
      StatLevel.intermediate => 'level_intermediate'.tr(),
      StatLevel.advanced => 'level_advanced'.tr(),
    };
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.percentage});

  final int? percentage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(3.r),
      child: Container(
        height: 6.h,
        color: colors.trackBackground,
        child: FractionallySizedBox(
          // `centerStart` لا `centerLeft`: الشريط بيتعبّى من اليمين بالعربي.
          alignment: AlignmentDirectional.centerStart,
          widthFactor: (percentage ?? 0) / 100,
          child: Container(color: context.scheme.primary),
        ),
      ),
    );
  }
}
