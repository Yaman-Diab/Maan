// -------------------------
// Profile Avatar
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';

/// صورة المواطن — حرفَي اسمه داخل دائرة.
///
/// **ليش أحرف بدل صورة؟** التصميم بيحط مكانها `<image-slot>` بعبارة
/// «Drop photo»، وهاي أداة محرّر التصميم (بتسحب صورة عالمعاينة) لا عنصر
/// واجهة. وبالتطبيق ما في صورة أصلاً: `/api/profile` ما بيرجّع حقل صورة
/// وما في endpoint للرفع، فحتى زر «غيّر الصورة» بيكون زر لا مكان يوصله.
///
/// الأحرف حل قياسي بلا شبكة وبلا إذن كاميرا، وبيصير استبداله بـ
/// `Image.network` بسطر واحد يوم يوصل حقل الصورة.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.firstName, required this.lastName});

  final String firstName;
  final String lastName;

  /// 112px بالتصميم.
  static const double _diameter = 112;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;

    return Container(
      width: _diameter.w,
      height: _diameter.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.brandSurface,
        shape: BoxShape.circle,
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Text(
        _initials,
        style: context.texts.f32W600Black.copyWith(
          fontSize: 34.sp,
          color: scheme.primary,
        ),
      ),
    );
  }

  /// أول حرف من كل اسم. بتشتغل بالعربي والإنجليزي لأنها ما بتفترض أبجدية.
  String get _initials {
    final first = _firstLetter(firstName);
    final last = _firstLetter(lastName);
    final initials = '$first$last';

    // اسم فاضي ما بيصير — بس لو صار، دائرة فاضية أحسن من رمز غريب.
    return initials.isEmpty ? '' : initials.toUpperCase();
  }

  static String _firstLetter(String value) {
    final trimmed = value.trim();

    return trimmed.isEmpty ? '' : trimmed.characters.first;
  }
}
