// -------------------------
// News Card
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/place_name_text.dart';
import '../../../domain/entities/news_item.dart';

/// بطاقة خبر — نسختان بنفس الشكل: `compact` لشريط الرئيسية الأفقي
/// (عرض ثابت)، والعادية لتاب الأخبار (عرض كامل).
///
/// ⚠️ **بلا شارة نوع** — «خبر» و«إعلان» نفس الشي بتطبيق المواطن، فما
/// في تمييز بصري بينهم (راجع `NewsItem`).
class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.item, this.compact = false});

  final NewsItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;

    return Container(
      width: compact ? 255.w : double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        boxShadow: AppShadows.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.hasImage)
            SizedBox(
              height: compact ? 118.h : 160.h,
              width: double.infinity,
              child: Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => ColoredBox(
                  color: colors.fieldDisabledBackground,
                  child: Icon(
                    Icons.image_rounded,
                    size: 28.sp,
                    color: colors.textHint,
                  ),
                ),
              ),
            )
          else
            // شريط رفيع بلون الهوية بدل الصورة — بيحافظ على إيقاع
            // البطاقات بالشريط الأفقي بلا مساحة فاضية كبيرة.
            Container(height: 4.h, color: scheme.primary),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.f14W600Black.copyWith(height: 1.4),
                ),
                if (item.description != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    item.description!,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.f12W400SecColor.copyWith(height: 1.45),
                  ),
                ],
                if (!compact && item.hasLocation) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14.sp,
                        color: colors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: PlaceNameText(
                          latitude: item.latitude!,
                          longitude: item.longitude!,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (item.publishedAt != null) ...[
                  SizedBox(height: 9.h),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14.sp,
                        color: colors.textHint,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        item.publishedAt!.toLocal().toString().split(' ').first,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: colors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
