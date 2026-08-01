// -------------------------
// Account Status Chip
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/session/account_status.dart';

/// شارة حالة الحساب.
///
/// التصميم بيغطي حالتين (موثّق / غير موثّق)، بس [AccountStatus] فيها
/// خمسة. الباقي ما بينعرض كـ«غير موثّق» تعميماً — «محظور» و«بانتظار
/// التحقق» حالتان مختلفتان تماماً بالمعنى وبالإجراء المطلوب من المستخدم.
///
/// [AccountStatus.unknown] بترجّع `null`: أفضل ما نعرض شي من إننا نأكّد
/// حالة ما منعرفها.
class AccountStatusChip extends StatelessWidget {
  const AccountStatusChip({super.key, required this.status});

  final AccountStatus status;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(context, status);

    if (style == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(9.w, 5.h, 12.w, 5.h),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 15.sp, color: style.foreground),
          SizedBox(width: 5.w),

          // `Flexible` جوّا صف بـ`mainAxisSize.min`: بياخد حجمه الطبيعي
          // بالوضع العادي، وبينكمش بدل ما يفيض لما يكبّر المستخدم الخط.
          Flexible(
            child: Text(
              style.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.texts.f12W400SecColor.copyWith(
                fontWeight: FontWeight.w500,
                color: style.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ChipStyle? _styleFor(BuildContext context, AccountStatus status) {
    final colors = context.colors;
    final scheme = context.scheme;

    return switch (status) {
      AccountStatus.verified => _ChipStyle(
        icon: Icons.check_circle_rounded,
        label: 'account_status_verified'.tr(),
        foreground: colors.success,
        background: colors.successSurface,
      ),
      AccountStatus.visitor => _ChipStyle(
        icon: Icons.error_rounded,
        label: 'account_status_not_verified'.tr(),
        foreground: colors.noticeForeground,
        background: colors.noticeBackground,
      ),
      AccountStatus.pendingVerification => _ChipStyle(
        icon: Icons.schedule_rounded,
        label: 'account_status_pending'.tr(),
        foreground: colors.noticeForeground,
        background: colors.noticeBackground,
      ),
      AccountStatus.blocked => _ChipStyle(
        icon: Icons.block_rounded,
        label: 'account_status_blocked'.tr(),
        foreground: scheme.error,
        background: scheme.errorContainer,
      ),
      AccountStatus.unknown => null,
    };
  }
}

class _ChipStyle {
  const _ChipStyle({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
}
