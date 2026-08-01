// -------------------------
// Profile Avatar
// -------------------------

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';

/// صورة المواطن، وإذا ما في صورة فحرفَي اسمه.
///
/// ترتيب الأولوية: [localImagePath] (اللي رفعها هالجلسة) ← [imageUrl]
/// (من السيرفر) ← الأحرف. المحلي أولاً لأنه أحدث، وكمان بيشتغل حتى لو
/// الباك اند ما رجّع رابطاً بعد الرفع (العقد لسه غير مثبّت).
///
/// ملاحظة عن التصميم: المكان مرسوم بـ`<image-slot placeholder="Drop
/// photo">` — وهاي أداة محرّر التصميم لا عنصر واجهة. البديل على الجوال
/// زر «+» بيفتح الكاميرا أو المعرض.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.firstName,
    required this.lastName,
    this.imageUrl,
    this.localImagePath,
    this.isUploading = false,
    this.onAddPhotoTap,
  });

  final String firstName;
  final String lastName;
  final String? imageUrl;
  final String? localImagePath;
  final bool isUploading;

  /// لما تكون `null` ما بينعرض زر «+» — للعرض للقراءة فقط.
  final VoidCallback? onAddPhotoTap;

  /// 112px بالتصميم.
  static const double _diameter = 112;

  /// شارة الـ«+» — كبيرة كفاية للمس (48px فعلي مع الهالة).
  static const double _badgeDiameter = 34;

  @override
  Widget build(BuildContext context) {
    final size = _diameter.w;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _Circle(size: size, child: _content(context)),

          if (isUploading) _Circle(size: size, child: const _UploadingVeil()),

          if (onAddPhotoTap != null && !isUploading)
            PositionedDirectional(
              // `Directional` لا `left/right`: الشارة بتنتقل لليسار
              // بالعربي مع باقي التخطيط.
              bottom: 0,
              end: 0,
              child: _AddPhotoBadge(onTap: onAddPhotoTap!),
            ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    final local = localImagePath;

    if (local != null) {
      return Image.file(
        File(local),
        fit: BoxFit.cover,
        // ملف مؤقّت ممكن ينمسح من النظام — وقتها بنرجع للأحرف بدل ما
        // تطلع أيقونة صورة مكسورة.
        errorBuilder: (context, _, _) => _initialsBox(context),
      );
    }

    final url = imageUrl;

    if (url != null) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, _, _) => _initialsBox(context),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return _initialsBox(context);
        },
      );
    }

    return _initialsBox(context);
  }

  Widget _initialsBox(BuildContext context) {
    return ColoredBox(
      color: context.colors.brandSurface,
      child: Center(
        child: Text(
          _initials,
          style: context.texts.f32W600Black.copyWith(
            fontSize: 34.sp,
            color: context.scheme.primary,
          ),
        ),
      ),
    );
  }

  /// أول حرف من كل اسم. بتشتغل بالعربي والإنجليزي لأنها ما بتفترض أبجدية.
  String get _initials {
    final initials = '${_firstLetter(firstName)}${_firstLetter(lastName)}';

    return initials.toUpperCase();
  }

  static String _firstLetter(String value) {
    final trimmed = value.trim();

    return trimmed.isEmpty ? '' : trimmed.characters.first;
  }
}

/// الإطار الدائري المشترك — بيقصّ الصورة وبيرسم الحدّ.
class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.child});

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.scheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}

class _UploadingVeil extends StatelessWidget {
  const _UploadingVeil();

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return ColoredBox(
      color: scheme.scrim,
      child: Center(
        child: SizedBox(
          width: 28.w,
          height: 28.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: scheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _AddPhotoBadge extends StatelessWidget {
  const _AddPhotoBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final size = ProfileAvatar._badgeDiameter.w;

    return Material(
      color: scheme.primary,
      shape: CircleBorder(
        // حلقة بلون الخلفية بتفصل الشارة عن الصورة تحتها مهما كان لونها.
        side: BorderSide(color: context.colors.pageBackground, width: 2.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(Icons.add_rounded, size: 20.sp, color: scheme.onPrimary),
        ),
      ),
    );
  }
}
