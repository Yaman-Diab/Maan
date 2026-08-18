// -------------------------
// App Progress Bar
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_theme_context.dart';

/// شريط تقدّم أفقي بنسبة مئوية.
///
/// انتقل لـ`core` من `StatIndexCard._ProgressBar` (الملف الشخصي) لما
/// احتاجته بطاقة المشروع لشريط التبرعات — نفس سبب `AppCard`/
/// `ImageSourceSheet`: ودجت عرض بحت بلا اعتماديّة domain، مستهلَك من
/// ميزتين.
///
/// ⚠️ **`AlignmentDirectional.centerStart` لا `centerLeft`** — الشريط
/// لازم يتعبّى من اليمين بالواجهة العربية. `centerLeft` بيخلّيه يتعبّى
/// من اليسار دائماً فيبان مقلوباً.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.percentage,
    this.height = 6,
    this.color,
  });

  /// `null` بتعرض شريطاً فاضياً بدل رقم مخترع — الملف الشخصي بيستعملها
  /// لما الباك اند ما بيرجّع المؤشّر.
  final int? percentage;

  final double height;

  /// `null` = لون الهوية. بطاقة التبرعات بتمرّر اللون الكهرماني حتى
  /// تتّسق مع زر «تبرّع».
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final safePercentage = ((percentage ?? 0).clamp(0, 100)) / 100;

    return ClipRRect(
      borderRadius: BorderRadius.circular((height / 2).r),
      child: Container(
        height: height.h,
        color: context.colors.trackBackground,
        child: FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: safePercentage,
          child: Container(color: color ?? context.scheme.primary),
        ),
      ),
    );
  }
}
