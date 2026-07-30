import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

import '../widgets/splash_backdrop.dart';
import '../widgets/splash_loading_dots.dart';
import '../widgets/splash_logo.dart';

/// شاشة البداية.
///
/// عرض بحت — ما بتقرّر متى تنتهي. `AppSessionController.bootstrap()`
/// بيقلب `isInitialized`، فيشتغل `AppRedirect` وينقل المستخدم للرئيسية
/// أو لتسجيل الدخول. فلو صار الإقلاع بطيئاً، الشاشة بتبقى معروضة
/// بحركتها بدل ما تقفز على مؤقّت وهمي.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// مدة حركة الدخول كاملة: آخر عنصر (الوصف) بيبدأ بعد 0.35s وبياخد
  /// 0.7s، فبتخلص عند 1.05s.
  static const Duration entranceDuration = Duration(milliseconds: 1050);

  /// أقل مدة تُعرض فيها الشاشة، بتمررها `main.dart` لـ`bootstrap`.
  ///
  /// = مدة الحركة + نصف ثانية لقراءة السطر. بلا هالحدّ الإقلاع بيخلص
  /// بعشرات الملي ثانية والحركة ما بتكتمل أبداً.
  ///
  /// أطول من هيك بتصير الشاشة ساكنة والمستخدم بيحسّ بالانتظار — Material
  /// وApple HIG الاثنان بينصحوا بعدم إطالة شاشة البداية.
  static const Duration minimumDuration = Duration(milliseconds: 3000);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  /// دورة الحلقات النابضة — 3s بالتصميم.
  late final AnimationController _rings = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  /// دورة نقاط التحميل — 1.2s بالتصميم.
  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  /// دخول العناصر مرة وحدة: البطاقة ثم العنوان ثم الوصف.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: SplashPage.entranceDuration,
  )..forward();

  late final Animation<double> _cardIn = CurvedAnimation(
    parent: _entrance,
    // 0.65s من أصل 1.05s
    curve: const Interval(0, 0.62, curve: Curves.easeOut),
  );

  late final Animation<double> _titleIn = CurvedAnimation(
    parent: _entrance,
    // تأخير 0.2s ثم 0.7s
    curve: const Interval(0.19, 0.86, curve: Curves.easeOut),
  );

  late final Animation<double> _subtitleIn = CurvedAnimation(
    parent: _entrance,
    // تأخير 0.35s ثم 0.7s
    curve: const Interval(0.33, 1, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _rings.dispose();
    _dots.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final texts = context.texts;

    return Scaffold(
      body: Stack(
        children: [
          const SplashBackdrop(),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // التصميم بيرفع الكتلة 40px فوق المنتصف ليفسح للنقاط.
                Transform.translate(
                  offset: Offset(0, -40.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SplashLogo(
                        ringAnimation: _rings,
                        cardAnimation: _cardIn,
                      ),

                      SizedBox(height: 36.h),

                      _FadeUp(
                        animation: _titleIn,
                        child: Text(
                          'splash_title'.tr(),
                          textAlign: TextAlign.center,
                          style: texts.f16W500Black.copyWith(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w700,
                            color: context.scheme.primary,
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      _FadeUp(
                        animation: _subtitleIn,
                        child: _SubtitleWithRules(
                          text: 'splash_subtitle'.tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 76.h,
            child: SplashLoadingDots(animation: _dots),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 34.h,
            child: Text(
              'loading'.tr(),
              textAlign: TextAlign.center,
              style: texts.f14W400HintColor.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ظهور تدريجي مع صعود 12px — `maan-fade-up` بالتصميم.
class _FadeUp extends StatelessWidget {
  const _FadeUp({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 12.h * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// الوصف بين خطّين قصيرين.
class _SubtitleWithRules extends StatelessWidget {
  const _SubtitleWithRules({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rule = SizedBox(
      width: 26.w,
      child: Divider(
        height: 1.h,
        thickness: 1.h,
        color: colors.textSecondary.withValues(alpha: 0.5),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        rule,
        SizedBox(width: 10.w),
        Text(
          text,
          style: context.texts.f14W400HintColor.copyWith(
            fontSize: 13.sp,
            color: colors.textSecondary,
          ),
        ),
        SizedBox(width: 10.w),
        rule,
      ],
    );
  }
}
