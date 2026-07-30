import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_assets.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

/// الشعار داخل بطاقة بيضاء، وحولها ثلاث حلقات نابضة.
///
/// كل حلقة بتاخد نفس المنحنى بإزاحة زمنية (0 · 1/3 · 2/3 من الدورة)،
/// فبتطلع موجة متتابعة من `AnimationController` واحد بدل ثلاثة.
class SplashLogo extends StatelessWidget {
  const SplashLogo({
    super.key,
    required this.ringAnimation,
    required this.cardAnimation,
  });

  /// دورة متكررة قيمتها 0→1 كل 3 ثوانٍ.
  final Animation<double> ringAnimation;

  /// دخول البطاقة مرة وحدة عند فتح الشاشة.
  final Animation<double> cardAnimation;

  static const double _size = 330;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return SizedBox(
      width: _size.w,
      height: _size.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _Ring(animation: ringAnimation, color: scheme.primary, phase: 0),
          _Ring(
            animation: ringAnimation,
            color: scheme.primary,
            phase: 1 / 3,
          ),
          _Ring(
            animation: ringAnimation,
            color: scheme.secondary,
            phase: 2 / 3,
            opacity: 0.28,
          ),
          _LogoCard(animation: cardAnimation),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({
    required this.animation,
    required this.color,
    required this.phase,
    this.opacity = 0.30,
  });

  final Animation<double> animation;
  final Color color;

  /// إزاحة الحلقة ضمن الدورة، من 0 لـ 1.
  final double phase;

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // `% 1` بتلفّ الدورة، فالحلقة المزاحة بتكمل من البداية.
        final t = (animation.value + phase) % 1;

        // التصميم: 0% → scale .55 وشفافية 0، 20% → شفافية 0.9،
        // 100% → scale 1.35 وشفافية 0.
        final scale = 0.55 + (1.35 - 0.55) * t;
        final fade = t < 0.2 ? t / 0.2 : 1 - (t - 0.2) / 0.8;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: (fade * 0.9).clamp(0.0, 1.0) * (opacity / 0.30),
            child: child,
          ),
        );
      },
      child: Container(
        width: SplashLogo._size.w,
        height: SplashLogo._size.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity),
            width: 2.w,
          ),
        ),
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.scale(
            scale: 0.94 + 0.06 * animation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 30.h),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.14),
              offset: Offset(0, 18.h),
              blurRadius: 40.r,
            ),
            BoxShadow(
              color: context.colors.textPrimary.withValues(alpha: 0.05),
              offset: Offset(0, 2.h),
              blurRadius: 6.r,
            ),
          ],
        ),
        child: Image.asset(
          AppAssets.maanLogo,
          width: 206.w,
          fit: BoxFit.contain,
          // الشعار هو اسم التطبيق مكتوباً، فبيتقرأ كنص لقارئ الشاشة.
          semanticLabel: 'app_name'.tr(),
        ),
      ),
    );
  }
}
