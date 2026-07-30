import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_assets.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/features/splash/presentation/pages/splash_page.dart';
import 'package:maan/features/splash/presentation/widgets/splash_loading_dots.dart';
import 'package:maan/features/splash/presentation/widgets/splash_logo.dart';

const _designSize = Size(375, 812);

Future<void> _pumpSplash(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _designSize;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) =>
          MaterialApp(theme: AppTheme.light(), home: const SplashPage()),
    ),
  );

  // pumpAndSettle بتعلّق مع الحركات اللانهائية (الحلقات والنقاط)،
  // فبنقدّم الوقت يدوياً.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('بترسم الشعار والنقاط بلا استثناء', (tester) async {
    await _pumpSplash(tester);

    expect(find.byType(SplashLogo), findsOneWidget);
    expect(find.byType(SplashLoadingDots), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('بتعرض الشعار من الأصول المسجّلة', (tester) async {
    await _pumpSplash(tester);

    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image as AssetImage;

    expect(provider.assetName, AppAssets.maanLogo);
  });

  testWidgets('النصوص بتيجي من الترجمة لا مكتوبة يدوياً', (tester) async {
    await _pumpSplash(tester);

    // بلا تهيئة easy_localization بترجّع `.tr()` المفتاح نفسه، فوجوده
    // بيثبت إن النص مربوط بالترجمة.
    expect(find.text('splash_title'), findsOneWidget);
    expect(find.text('splash_subtitle'), findsOneWidget);
    expect(find.text('loading'), findsOneWidget);
  });

  testWidgets('الحركات بتستمر بلا أخطاء عبر عدة دورات', (tester) async {
    await _pumpSplash(tester);

    // دورة الحلقات 3s ودورة النقاط 1.2s — بنتجاوز الاثنتين.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('بتتخلّص من المتحكّمات عند الخروج', (tester) async {
    await _pumpSplash(tester);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));

    // متحكّم متكرر ما انتخلّص منه بيرمي عند أول إطار بعد الإزالة.
    expect(tester.takeException(), isNull);
  });

  testWidgets('بتشتغل بالوضع الداكن كمان', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _designSize;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _designSize,
        builder: (context, child) => MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: const SplashPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SplashLogo), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
