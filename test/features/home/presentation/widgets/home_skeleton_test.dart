import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/features/home/presentation/home/widgets/home_skeleton.dart';

const _designSize = Size(375, 812);

/// ⚠️ باگ حقيقي انصلح: هيكل التحميل الأول كان فيه `Row` أفقي بعرض
/// ثابت (255.w + 120.w) بيتجاوز عرض هاتف حقيقي — نفس باگ
/// `NewsSkeleton`، وانصلح بنفس الأسلوب (استخدام `NewsSkeleton`
/// المصلَّحة بدل تكرار Row مماثل). هالاختبار بعرض هاتف ضيق فعلي عمداً.
void main() {
  testWidgets('بلا overflow بعرض هاتف ضيق', (tester) async {
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
          home: const Scaffold(body: HomeSkeleton()),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
