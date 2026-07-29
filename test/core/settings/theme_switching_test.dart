import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_semantic_colors.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/settings/cubit/settings_state.dart';
import 'package:maan/core/settings/widgets/text_scale_scope.dart';

/// التحقق من أن التبديل شغّال على شجرة حقيقية، لا على الثيمات لحالها.
///
/// بيحاكي نفس تركيب `main.dart`: ScreenUtilInit ← MaterialApp
/// (theme + darkTheme + themeMode) ← TextScaleScope.
const _designSize = Size(375, 812);

Future<({ThemeData theme, TextScaler scaler})> _pump(
  WidgetTester tester, {
  required ThemeMode themeMode,
  AppTextScale textScale = AppTextScale.normal,
  Brightness platformBrightness = Brightness.light,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _designSize;
  tester.platformDispatcher.platformBrightnessTestValue = platformBrightness;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearPlatformBrightnessTestValue();
  });

  late ThemeData theme;
  late TextScaler scaler;

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        builder: (context, child) =>
            TextScaleScope(scale: textScale, child: child),
        home: Builder(
          builder: (context) {
            theme = Theme.of(context);
            scaler = MediaQuery.textScalerOf(context);
            return const Text('معاً');
          },
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
  return (theme: theme, scaler: scaler);
}

void main() {
  group('تبديل الثيم', () {
    testWidgets('ThemeMode.dark بيعطي الثيم الداكن', (tester) async {
      final result = await _pump(tester, themeMode: ThemeMode.dark);

      expect(result.theme.brightness, Brightness.dark);
      expect(
        result.theme.extension<AppSemanticColors>(),
        AppSemanticColors.dark,
      );
    });

    testWidgets('ThemeMode.light بيعطي الفاتح حتى لو النظام داكن', (
      tester,
    ) async {
      final result = await _pump(
        tester,
        themeMode: ThemeMode.light,
        platformBrightness: Brightness.dark,
      );

      expect(result.theme.brightness, Brightness.light);
      expect(
        result.theme.extension<AppSemanticColors>(),
        AppSemanticColors.light,
      );
    });

    testWidgets('ThemeMode.system بيتبع النظام', (tester) async {
      final dark = await _pump(
        tester,
        themeMode: ThemeMode.system,
        platformBrightness: Brightness.dark,
      );
      expect(dark.theme.brightness, Brightness.dark);

      final light = await _pump(
        tester,
        themeMode: ThemeMode.system,
        platformBrightness: Brightness.light,
      );
      expect(light.theme.brightness, Brightness.light);
    });
  });

  group('حجم الخط', () {
    testWidgets('normal ما بتغيّر شي', (tester) async {
      final result = await _pump(
        tester,
        themeMode: ThemeMode.light,
        textScale: AppTextScale.normal,
      );

      expect(result.scaler.scale(16), 16);
    });

    testWidgets('large بتكبّر النص فعلياً', (tester) async {
      final result = await _pump(
        tester,
        themeMode: ThemeMode.light,
        textScale: AppTextScale.large,
      );

      expect(result.scaler.scale(16), closeTo(16 * 1.15, 0.01));
    });

    testWidgets('small بتصغّر', (tester) async {
      final result = await _pump(
        tester,
        themeMode: ThemeMode.light,
        textScale: AppTextScale.small,
      );

      expect(result.scaler.scale(16), closeTo(16 * 0.9, 0.01));
    });
  });

  group('TextScaleScope.resolveScale', () {
    test('بتضرب تفضيل المستخدم بإعداد النظام لا بتستبدله', () {
      // مستخدم كبّر الخط من إعدادات الجهاز لأسباب إتاحة.
      final withSystemScaling = TextScaleScope.resolveScale(
        systemScale: 1.3,
        preference: AppTextScale.normal,
      );

      expect(
        withSystemScaling,
        1.3,
        reason: 'تفضيل "عادي" ما لازم يلغي تكبير النظام',
      );
    });

    test('بتجمع الاثنين', () {
      expect(
        TextScaleScope.resolveScale(
          systemScale: 1.2,
          preference: AppTextScale.large,
        ),
        closeTo(1.2 * 1.15, 0.001),
      );
    });

    test('بتحدّ الأعلى حتى ما ينكسر التخطيط', () {
      expect(
        TextScaleScope.resolveScale(
          systemScale: 2.5,
          preference: AppTextScale.extraLarge,
        ),
        TextScaleScope.maxScale,
      );
    });

    test('بتحدّ الأدنى حتى يضل النص مقروء', () {
      expect(
        TextScaleScope.resolveScale(
          systemScale: 0.5,
          preference: AppTextScale.small,
        ),
        TextScaleScope.minScale,
      );
    });
  });
}
