// -------------------------
// Identity Info Card
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../auth/domain/entities/auth_user.dart';
import 'profile_card.dart';

/// بيانات الهوية بشبكة 2×2.
///
/// صفّان بدل `GridView`: العدد ثابت (أربعة حقول)، والـ `Row` بتنعكس
/// تلقائياً بالعربي بينما الشبكة بدها ضبط اتجاه يدوي.
class IdentityInfoCard extends StatelessWidget {
  const IdentityInfoCard({super.key, required this.user});

  final AuthUser user;

  /// اللي بينعرض مطرح القيمة الناقصة — الباك اند بيرجّع `null` للرقم
  /// الوطني قبل التوثيق.
  static const String _missingValue = '—';

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Field(label: 'first_name'.tr(), value: user.firstName),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _Field(label: 'last_name'.tr(), value: user.lastName),
              ),
            ],
          ),

          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Field(
                  label: 'national_id'.tr(),
                  value: user.nationalId ?? _missingValue,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _Field(
                  label: 'date_of_birth'.tr(),
                  value: _formatDate(user.birthDate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// `12 / 10 / 1998` — يوم/شهر/سنة متل التصميم.
  ///
  /// بأرقام لاتينية بالعربي كمان: باقي التطبيق (طول الرمز، العمر) بيعرضها
  /// هيك، والخلط بين ١٢ و12 بنفس الشاشة أسوأ من الاثنين.
  static String _formatDate(DateTime? date) {
    if (date == null) return _missingValue;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day / $month / ${date.year}';
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final texts = context.texts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: texts.f14W400HintColor.copyWith(
            fontSize: 13.sp,
            color: context.colors.textSecondary,
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          value,
          style: texts.f14W600Black.copyWith(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
