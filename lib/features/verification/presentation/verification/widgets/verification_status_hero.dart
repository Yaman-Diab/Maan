// -------------------------
// Verification Status Hero
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// الأيقونة الدائرية المتحرّكة اللي بتتصدّر عروض «قيد المراجعة» و«مرفوض»
/// و«معتمد».
///
/// ودجت واحد بثلاث ألوان بدل ثلاث نسخ: التصميم بيستخدم نفس البنية
/// حرفياً (حلقات متمدّدة + قرص داخلي بيكبر مرة وحدة) وبس بيبدّل اللون
/// والأيقونة.
///
/// ⚠️ **الحلقات بتتوقّف لما `showRings` تكون false** — عرض «مرفوض» ما
/// إله حلقات مستمرة بالتصميم لأنها حالة نهائية لا انتظار.
class VerificationStatusHero extends StatefulWidget {
  const VerificationStatusHero({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.showRings = true,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final bool showRings;

  @override
  State<VerificationStatusHero> createState() => _VerificationStatusHeroState();
}

class _VerificationStatusHeroState extends State<VerificationStatusHero>
    with TickerProviderStateMixin {
  /// حلقة وحدة بمتحكّم واحد، والثانية بتاخد نفس المنحنى بإزاحة زمنية —
  /// نفس نمط شاشة البداية (`splash`) بدل متحكّم لكل عنصر متكرر.
  late final AnimationController _rings = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void initState() {
    super.initState();

    _pop.forward();
    if (widget.showRings) _rings.repeat();
  }

  @override
  void dispose() {
    _rings.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150.w,
      height: 150.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.showRings) ...[
            _Ring(controller: _rings, color: widget.color, delay: 0),
            _Ring(controller: _rings, color: widget.color, delay: .32),
          ],
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _pop,
              curve: const Cubic(.2, .8, .3, 1),
            ),
            child: Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: widget.color),
              ),
              child: Icon(widget.icon, size: 40.sp, color: widget.color),
            ),
          ),
        ],
      ),
    );
  }
}

/// حلقة بتتمدّد وبتختفي. [delay] كسر من الدورة (0..1) — الإزاحة بتصير
/// على القيمة نفسها لا بمؤقّت، فالحلقتان بتضلّا متزامنتين تماماً.
class _Ring extends StatelessWidget {
  const _Ring({
    required this.controller,
    required this.color,
    required this.delay,
  });

  final AnimationController controller;
  final Color color;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value + delay) % 1.0;

        return Opacity(
          opacity: (1 - t) * .55,
          child: Transform.scale(scale: .75 + t * .75, child: child),
        );
      },
      child: Container(
        width: 96.w,
        height: 96.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color),
        ),
      ),
    );
  }
}
