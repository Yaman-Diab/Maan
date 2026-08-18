import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/features/news/presentation/news/widgets/news_skeleton.dart';

const _designSize = Size(375, 812);

/// ⚠️ باگ حقيقي انصلح: `Row` أفقي بعرض ثابت (255.w + 120.w) بيتجاوز
/// عرض شاشة هاتف حقيقي وبيرمي "RenderFlex overflowed" وقت التشغيل —
/// خطأ layout ما بيمسكه `flutter analyze`. الإصلاح تغليف بـ
/// `SingleChildScrollView` أفقي. هالاختبار بيثبّت عرض الجهاز على
/// عرض هاتف ضيق فعلي (375) عمداً — بيئة الاختبار الافتراضية (800)
/// ما كانت رح تلقط الباگ أصلاً.
void main() {
  Future<void> pumpAtWidth(
    WidgetTester tester, {
    bool horizontal = false,
  }) async {
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
          home: Scaffold(body: NewsSkeleton(horizontal: horizontal)),
        ),
      ),
    );
  }

  testWidgets('النسخة الأفقية بلا overflow بعرض هاتف ضيق', (tester) async {
    await pumpAtWidth(tester, horizontal: true);

    expect(tester.takeException(), isNull);
  });

  testWidgets('النسخة العمودية بلا overflow بعرض هاتف ضيق', (tester) async {
    await pumpAtWidth(tester);

    expect(tester.takeException(), isNull);
  });
}
