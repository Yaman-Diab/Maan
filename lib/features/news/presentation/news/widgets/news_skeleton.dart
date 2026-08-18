// -------------------------
// News Skeleton
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';

/// هيكل تحميل أول فتح لتاب الأخبار — بطاقتان وهميتان بشكل عام
/// (`Bone` بس)، نفس قرار `SkillsSkeleton`/`ComplaintsSkeleton`.
class NewsSkeleton extends StatelessWidget {
  const NewsSkeleton({super.key, this.horizontal = false});

  /// نسخة الشريط الأفقي بالرئيسية — بطاقة بعرض ثابت بدل عرض كامل.
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final effect = ShimmerEffect(
      baseColor: colors.fieldDisabledBackground,
      highlightColor: colors.fieldBackground,
    );

    if (horizontal) {
      // ⚠️ `SingleChildScrollView` لا `Row` مباشرة — عرض البطاقتين
      // (255.w + 120.w) بيتجاوز عرض الشاشة المتاح، وبلا تغليف بيرمي
      // `RenderFlex overflowed` وقت التشغيل الحقيقي (خطأ layout ما
      // بيمسكه `flutter analyze`). نفس شكل السلوك الحقيقي المتحرك.
      return Skeletonizer(
        effect: effect,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              _CardSkeleton(width: 255.w),
              SizedBox(width: AppSpacing.sm.w),
              _CardSkeleton(width: 120.w),
            ],
          ),
        ),
      );
    }

    return Skeletonizer(
      effect: effect,
      child: Column(
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
  const _CardSkeleton({this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone(height: 118.h, width: double.infinity),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(width: (width ?? 240.w) * 0.75),
                SizedBox(height: 8.h),
                Bone.text(width: (width ?? 240.w) * 0.5, fontSize: 11.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
