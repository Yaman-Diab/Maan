// -------------------------
// Projects Skeleton
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';

/// هيكل تحميل بطاقات المشاريع — شكل عام بـ`Bone`، نفس قرار باقي
/// الهياكل بالمشروع (تلفيق حالة لبطاقة فيها حوارات وأزرار مشروطة أعقد
/// من الفايدة).
class ProjectsSkeleton extends StatelessWidget {
  const ProjectsSkeleton({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: colors.fieldDisabledBackground,
        highlightColor: colors.fieldBackground,
      ),
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            const _CardSkeleton(),
            if (i != count - 1) SizedBox(height: AppSpacing.sm.h),
          ],
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone(
                width: 44.w,
                height: 44.w,
                borderRadius: BorderRadius.circular(AppRadius.pill.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(width: 170.w),
                    SizedBox(height: 7.h),
                    Bone.text(width: 210.w, fontSize: 11.h),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Bone(
            height: 38.h,
            width: double.infinity,
            borderRadius: BorderRadius.circular(AppRadius.md.r),
          ),
        ],
      ),
    );
  }
}
