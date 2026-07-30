import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

/// ثلاث نقاط بتنطّ بالتتابع كمؤشّر تحميل.
///
/// نفس فكرة الحلقات: منحنى واحد بإزاحة زمنية لكل نقطة.
class SplashLoadingDots extends StatelessWidget {
  const SplashLoadingDots({super.key, required this.animation});

  /// دورة متكررة 0→1 كل 1.2 ثانية.
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Dot(animation: animation, color: scheme.primary, phase: 0),
        SizedBox(width: 10.w),
        _Dot(animation: animation, color: scheme.secondary, phase: 0.125),
        SizedBox(width: 10.w),
        _Dot(animation: animation, color: scheme.primary, phase: 0.25),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.animation,
    required this.color,
    required this.phase,
  });

  final Animation<double> animation;
  final Color color;

  /// إزاحة ضمن الدورة — 0.15s و0.3s من أصل 1.2s بالتصميم.
  final double phase;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = (animation.value + phase) % 1;

        // التصميم: 0% و80% و100% → شفافية .28 بلا إزاحة،
        // 40% → شفافية 1 وارتفاع 5px. بنبني مثلثاً حول 0.4.
        final double progress;
        if (t <= 0.4) {
          progress = t / 0.4;
        } else if (t <= 0.8) {
          progress = 1 - (t - 0.4) / 0.4;
        } else {
          progress = 0;
        }

        return Transform.translate(
          offset: Offset(0, -5.h * progress),
          child: Opacity(opacity: 0.28 + 0.72 * progress, child: child),
        );
      },
      child: Container(
        width: 9.w,
        height: 9.w,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
