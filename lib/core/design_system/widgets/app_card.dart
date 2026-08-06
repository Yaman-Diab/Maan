// -------------------------
// App Card
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_spacing.dart';

/// السطح الأبيض المرفوع اللي بتتكرر عليه كل أقسام أي شاشة.
///
/// كانت `ProfileCard` بميزة profile — انتقلت هون لما احتاجتها شاشة
/// الإعدادات كمان بنفس الشكل حرفياً؛ نفس سبب انتقال `BirthDate`.
///
/// اللون من `scheme.surface` لا من توكن جديد: هو أصلاً أبيض بالفاتح
/// و`darkSurface` بالداكن، بينما خلفية الصفحة `pageBackground` أغمق —
/// فالفرق اللي بيبيّن البطاقة موجود بالثيمين.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        boxShadow: AppShadows.shadowSm,
      ),
      child: child,
    );
  }
}
