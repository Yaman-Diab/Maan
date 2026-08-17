// -------------------------
// Skills Skeleton
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';

/// هيكل تحميل أول فتح لقائمة المهارات — بطاقتان وهميتان بشكل عام
/// (Bone بس)، نفس قرار `ComplaintsSkeleton`/`VerificationSkeleton`:
/// تلفيق حالة/معالجات لمس لبطاقة تفاعلية معقّدة أعقد من الفايدة.
class SkillsSkeleton extends StatelessWidget {
  const SkillsSkeleton({super.key});

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
          for (var i = 0; i < 2; i++) ...[
            const _CardSkeleton(),
            if (i != 1) SizedBox(height: AppSpacing.sm.h),
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
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone(
                width: 48.w,
                height: 48.w,
                borderRadius: BorderRadius.circular(12.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(width: 160.w),
                    SizedBox(height: 9.h),
                    Bone(
                      height: 22.h,
                      width: 140.w,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Bone(
            height: 44.h,
            width: double.infinity,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ],
      ),
    );
  }
}
