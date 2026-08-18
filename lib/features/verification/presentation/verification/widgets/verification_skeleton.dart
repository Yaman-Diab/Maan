// -------------------------
// Verification Skeleton
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_card.dart';

/// هيكل تحميل أول فتح للشاشة (`VerificationView.loading`) — بدل
/// `CircularProgressIndicator` بشكل مقارب لعرض النموذج (الأكثر شيوعاً:
/// مستخدم جديد أو عم يصحّح رقمه).
///
/// ⚠️ **بخلاف `ProfileSkeleton`، هاي مش تغليف لودجت حقيقي ببيانات
/// وهمية** — `VerificationFormView` الحقيقي محتاج `TextEditingController`
/// حي وcallbacks لاختيار الصور، وخانات الرفع الفاضية عندها إطار منقّط
/// مرسوم بـ`CustomPaint` (`DottedBorderBox`) ما بينحوّل لعظمة مفهومة.
/// تلفيق حالة/متحكّمات وهمية لهيك widget تفاعلي معقّد أعقد من الفايدة —
/// فهون بنبني تخطيط عام بسيط بـ`Bone` بس، مش نسخة عن النموذج الحقيقي.
/// أي تغيير مستقبلي بشكل النموذج ما بينعكس هون تلقائياً (بعكس البروفايل)،
/// وهاد تنازل واعٍ عن الدقّة البصرية مقابل بساطة الصيانة.
class VerificationSkeleton extends StatelessWidget {
  const VerificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: colors.fieldDisabledBackground,
        highlightColor: colors.fieldBackground,
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md.w,
          AppSpacing.xs.h,
          AppSpacing.md.w,
          AppSpacing.md.h,
        ),
        children: [
          // صندوق الشروط.
          Bone(
            width: double.infinity,
            height: 64.h,
            borderRadius: BorderRadius.circular(AppRadius.md.r),
          ),
          SizedBox(height: AppSpacing.sm.h),

          // بطاقة «البيانات الشخصية».
          const _CardSkeleton(rows: 3),
          SizedBox(height: AppSpacing.sm.h),

          // بطاقة الرقم الوطني — عنوان + حقل + سطر مساعدة.
          AppCard(
            padding: EdgeInsets.all(AppSpacing.md.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _CardHeaderSkeleton(),
                SizedBox(height: AppSpacing.sm.h),
                Bone.text(words: 1),
                SizedBox(height: AppSpacing.xxs.h),
                Bone(
                  width: double.infinity,
                  height: 48.h,
                  borderRadius: BorderRadius.circular(AppRadius.sm.r),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Bone.text(words: 4),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),

          // بطاقة الوثيقة — عنوان + خانتا رفع.
          AppCard(
            padding: EdgeInsets.all(AppSpacing.md.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _CardHeaderSkeleton(),
                SizedBox(height: AppSpacing.md.h),
                Row(
                  children: [
                    Expanded(
                      child: Bone(
                        height: 120.h,
                        borderRadius: BorderRadius.circular(AppRadius.md.r),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: Bone(
                        height: 120.h,
                        borderRadius: BorderRadius.circular(AppRadius.md.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md.h),

          // زر الإرسال.
          Bone.button(width: double.infinity, height: 52.h),
        ],
      ),
    );
  }
}

/// أيقونة مربّعة + عنوان — متكرّرة بأعلى كل بطاقة بالنموذج الحقيقي.
class _CardHeaderSkeleton extends StatelessWidget {
  const _CardHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Bone.square(
          size: 32.w,
          borderRadius: BorderRadius.circular(AppRadius.sm.r),
        ),
        SizedBox(width: AppSpacing.xs.w),
        Expanded(child: Bone.text(words: 2)),
      ],
    );
  }
}

/// بطاقة عنوان + صفوف «تسمية: قيمة» — بشكل بطاقة البيانات الشخصية.
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.rows});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardHeaderSkeleton(),
          SizedBox(height: AppSpacing.sm.h),
          for (var i = 0; i < rows; i++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Bone.text(words: 1), Bone.text(words: 2)],
            ),
            if (i != rows - 1) SizedBox(height: AppSpacing.xs.h),
          ],
        ],
      ),
    );
  }
}
