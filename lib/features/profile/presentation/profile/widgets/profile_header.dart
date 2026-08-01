// -------------------------
// Profile Header
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../auth/domain/entities/auth_user.dart';
import 'account_status_chip.dart';
import 'profile_avatar.dart';

/// الصورة والاسم والبريد وشارة الحالة.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final texts = context.texts;

    return Padding(
      padding: EdgeInsets.only(top: 22.h, bottom: 26.h),
      child: Row(
        children: [
          ProfileAvatar(firstName: user.firstName, lastName: user.lastName),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: texts.f16W500Black.copyWith(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // علامة التوثيق جنب الاسم — بتظهر للموثّق فقط.
                    if (user.accountStatus.canUseMunicipalityServices) ...[
                      SizedBox(width: 7.w),
                      Icon(
                        Icons.verified_rounded,
                        size: 19.sp,
                        color: context.scheme.primary,
                      ),
                    ],
                  ],
                ),

                SizedBox(height: 5.h),

                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: texts.f12W400SecColor.copyWith(
                    color: colors.textSecondary,
                  ),
                ),

                SizedBox(height: 8.h),

                AccountStatusChip(status: user.accountStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
