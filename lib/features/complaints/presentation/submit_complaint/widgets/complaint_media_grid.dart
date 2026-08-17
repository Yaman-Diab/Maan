// -------------------------
// Complaint Media Grid
// -------------------------

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/media/picked_complaint_media.dart';

/// شبكة صور/فيديو الشكوى — عناصر مختارة + خانة إضافة. بعكس خانة الرفع
/// المنقّطة تبع التوثيق (عنصر وحيد ثابت)، هون العدد متغيّر لحد
/// [SubmitComplaintState.maxMediaCount].
class ComplaintMediaGrid extends StatelessWidget {
  const ComplaintMediaGrid({
    super.key,
    required this.media,
    required this.canAddMore,
    required this.onAdd,
    required this.onRemove,
  });

  final List<PickedComplaintMedia> media;
  final bool canAddMore;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: media.length + (canAddMore ? 1 : 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemBuilder: (context, index) {
        if (index == media.length) {
          return _AddTile(onTap: onAdd);
        }

        return _MediaTile(item: media[index], onRemove: () => onRemove(index));
      },
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.item, required this.onRemove});

  final PickedComplaintMedia item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: colors.border),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: item.isVideo
                  ? ColoredBox(
                      color: colors.fieldDisabledBackground,
                      child: Icon(
                        Icons.movie_rounded,
                        size: 24.sp,
                        color: colors.textHint,
                      ),
                    )
                  : Image.file(
                      File(item.path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => ColoredBox(
                        color: colors.fieldDisabledBackground,
                        child: Icon(
                          Icons.image_rounded,
                          size: 24.sp,
                          color: colors.textHint,
                        ),
                      ),
                    ),
            ),
          ),
          PositionedDirectional(
            top: 3,
            end: 3,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(11.r),
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: context.scheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 3),
                  ],
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 15.sp,
                  color: context.scheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: context.colors.border,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.add_rounded,
            size: 24.sp,
            color: context.scheme.primary,
          ),
        ),
      ),
    );
  }
}
