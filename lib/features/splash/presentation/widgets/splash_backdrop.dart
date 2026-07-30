import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

/// خلفية شاشة البداية: تدرّج عمودي + هالتان لونيتان بالزوايا.
///
/// الهالتان مقصوصتان بحواف الشاشة (`overflow:hidden` بالتصميم)، وهون
/// بيقصّهم `ClipRect` تبع الـ `Stack` الأب.
class SplashBackdrop extends StatelessWidget {
  const SplashBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;

    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.splashGradientTop,
              colors.splashGradientMiddle,
              colors.pageBackground,
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70.h,
              right: -70.w,
              child: _Glow(size: 240, color: scheme.primary, opacity: 0.10),
            ),
            Positioned(
              bottom: -100.h,
              left: -80.w,
              child: _Glow(size: 280, color: scheme.secondary, opacity: 0.12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
          // التصميم بيوقف التدرّج عند 70% من نصف القطر.
          stops: const [0, 0.7],
        ),
      ),
    );
  }
}
