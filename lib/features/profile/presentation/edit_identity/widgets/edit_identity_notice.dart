// -------------------------
// Edit Identity Notice
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';

/// إشارة تحت البطاقة — تختلف حسب قابلية التعديل: ملاحظة خفيفة وإنت
/// عم تعدّل، أو تحذير بارز لمّا يكون الحساب موثّقاً.
class EditIdentityNotice extends StatelessWidget {
  const EditIdentityNotice({super.key, required this.isLocked});

  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    if (isLocked) return const _LockedBanner();

    return const _EditableHint();
  }
}

/// صف بسيط بلا خلفية — إشارة خفيفة إنه في مهلة للتعديل.
class _EditableHint extends StatelessWidget {
  const _EditableHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18.sp,
            color: context.scheme.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'edit_identity_editable_notice'.tr(),
              style: context.texts.f12W400SecColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// بنفس أسلوب `TermsNoticeBox` — خلفية كهرمانية للتحذير، لا للمعلومة.
class _LockedBanner extends StatelessWidget {
  const _LockedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 61.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.colors.noticeBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.colors.noticeForeground.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_rounded,
            size: 22.sp,
            color: context.colors.noticeForeground,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'edit_identity_locked_notice'.tr(),
              style: context.texts.f12W400SecColor.copyWith(
                color: context.colors.noticeForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
