// -------------------------
// Home Skeleton
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../news/presentation/news/widgets/news_skeleton.dart';

/// هيكل التحميل الأول للشاشة كاملة.
///
/// ⚠️ **هيكل واحد لكل الشاشة لا هيكل لكل قسم**: الأقسام بتنزل بالتوازي
/// وبتوصل بأوقات مختلفة، فهياكل منفصلة كانت رح تختفي وحدة وحدة
/// وتخلّي التخطيط يقفز أربع مرات. لما يوصل الملف الشخصي بتنكشف الشاشة
/// كاملة وكل قسم بيعرض حالته وقتها.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: colors.fieldDisabledBackground,
        highlightColor: colors.fieldBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone(
            height: 76.h,
            width: double.infinity,
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
          ),
          SizedBox(height: 22.h),
          Bone.text(width: 150.w),
          SizedBox(height: 12.h),
          // نفس هيكل الأخبار الأفقي الحقيقي (`NewsSkeleton`) — بلا
          // تكرار Row مماثل هون، وبلا احتمال overflow لأنه مُغلَّف
          // بـ`SingleChildScrollView` هناك.
          const NewsSkeleton(horizontal: true),
          SizedBox(height: 22.h),
          Bone.text(width: 130.w),
          SizedBox(height: 12.h),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                Expanded(
                  child: Bone(
                    height: 94.h,
                    borderRadius: BorderRadius.circular(AppRadius.lg.r),
                  ),
                ),
                if (i != 2) SizedBox(width: 11.w),
              ],
            ],
          ),
          SizedBox(height: 22.h),
          Bone.text(width: 140.w),
          SizedBox(height: 12.h),
          for (var i = 0; i < 2; i++) ...[
            Bone(
              height: 96.h,
              width: double.infinity,
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
            ),
            if (i != 1) SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }
}
