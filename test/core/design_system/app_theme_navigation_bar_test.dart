import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';

const _designSize = Size(375, 812);

/// ⚠️ باگ حقيقي انصلح: تسميات شريط الملاحة كانت تلف لسطرين وتكسر محاذاة
/// الأيقونات بحجم `NavigationBar` الافتراضي (`textTheme.labelMedium`،
/// 14sp بتصميم التطبيق) — أوسع من بلاغ المستخدم الأصلي («Complaints»
/// بس): قياس فعلي أثبت إن «Projects»/«Profile» الإنجليزية **و«الرئيسية»
/// العربية** كانت تلف كمان بنفس الحجم، بأي عرض هاتف من 320 لـ428. راجع
/// تعليق `AppTheme._build` › `navigationBarTheme`.
///
/// هالاختبار بيثبّت الإصلاح (8.5sp + تقصير `nav_complaints`→`Issues`)
/// بعرض هاتف ضيّق فعلي (375) لكل التسميات الخمسة بالعربي والإنجليزي —
/// كل ارتفاع لازم يطابق ارتفاع سطر واحد (نفس ارتفاع «News»/«الأخبار»
/// القصيرتين المضمونتين بسطر واحد)، لا ضعفه.
void main() {
  Widget wrap({required List<NavigationDestination> destinations}) {
    return ScreenUtilInit(
      designSize: _designSize,
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          bottomNavigationBar: NavigationBar(
            selectedIndex: 0,
            destinations: destinations,
          ),
        ),
      ),
    );
  }

  const enLabels = ['Home', 'Issues', 'News', 'Projects', 'Profile'];
  const arLabels = ['الرئيسية', 'الشكاوى', 'الأخبار', 'المشاريع', 'حسابي'];

  Future<void> expectAllSingleLine(
    WidgetTester tester,
    List<String> labels,
  ) async {
    await tester.pumpWidget(
      wrap(
        destinations: [
          for (final label in labels)
            NavigationDestination(icon: const Icon(Icons.circle), label: label),
        ],
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);

    // «News»/«الأخبار» تسميات قصيرة مضمونة بسطر واحد — مرجع الارتفاع.
    final referenceHeight = tester.getSize(find.text(labels[2])).height;

    for (final label in labels) {
      final height = tester.getSize(find.text(label)).height;
      expect(
        height,
        lessThan(referenceHeight * 1.3),
        reason: '"$label" wrapped to a second line',
      );
    }
  }

  testWidgets('التسميات الإنجليزية الخمسة بسطر واحد بعرض 375', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await expectAllSingleLine(tester, enLabels);
  });

  testWidgets('التسميات العربية الخمسة بسطر واحد بعرض 375', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await expectAllSingleLine(tester, arLabels);
  });

  testWidgets('بلا استثناء بعرض هاتف ضيّق فعلي (320)', (tester) async {
    tester.view.physicalSize = const Size(320, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await expectAllSingleLine(tester, enLabels);
  });
}
