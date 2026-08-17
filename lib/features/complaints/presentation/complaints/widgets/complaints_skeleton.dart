// -------------------------
// Complaints Skeleton
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';

/// هيكل تحميل أول فتح لقائمة الشكاوى — ثلاث بطاقات وهمية بشكل عام
/// (Bone بس)، مش تغليف `ComplaintCard` الحقيقي: البطاقة الحقيقية
/// بتحتاج `Complaint` كامل + معالجات لمس، وتلفيقها وهمياً أعقد من
/// الفايدة — نفس قرار `VerificationSkeleton`.
class ComplaintsSkeleton extends StatelessWidget {
  const ComplaintsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: colors.fieldDisabledBackground,
        highlightColor: colors.fieldBackground,
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < 3; i++) ...[
            const _CardSkeleton(),
            if (i != 2) SizedBox(height: AppSpacing.sm.h),
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
                width: 64.w,
                height: 64.w,
                borderRadius: BorderRadius.circular(12.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(width: 200.w),
                    SizedBox(height: 8.h),
                    Bone.text(width: 130.w),
                    SizedBox(height: 8.h),
                    Bone(
                      height: 24.h,
                      width: 150.w,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Bone.text(width: 100.w),
        ],
      ),
    );
  }
}
