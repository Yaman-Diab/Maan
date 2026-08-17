// -------------------------
// Municipal Services Skeleton
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';

/// هيكل تحميل أول فتح لقائمة الخدمات — بطاقات وهمية بشكل عام (Bone
/// بس)، نفس قرار `SkillsSkeleton`: تلفيق حالة وهمية لبطاقة بمنطق حساب
/// وتلوين أعقد من الفايدة.
class MunicipalServicesSkeleton extends StatelessWidget {
  const MunicipalServicesSkeleton({super.key});

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
          for (var i = 0; i < 4; i++) ...[
            const _CardSkeleton(),
            if (i != 3) SizedBox(height: AppSpacing.sm.h),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Bone(
            width: 48.w,
            height: 48.w,
            borderRadius: BorderRadius.circular(24.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(width: 130.w, fontSize: 13.h),
                SizedBox(height: 9.h),
                Bone.text(width: 90.w, fontSize: 15.h),
                SizedBox(height: 9.h),
                Bone.text(width: 110.w, fontSize: 11.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
