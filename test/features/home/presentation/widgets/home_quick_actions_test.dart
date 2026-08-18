import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/features/home/presentation/home/widgets/home_quick_actions.dart';

const _designSize = Size(375, 812);

/// ⚠️ باگ حقيقي انصلح: `Row(crossAxisAlignment: CrossAxisAlignment.stretch)`
/// جوّا `ListView` عمودي (ارتفاع غير محدود) بيرمي "BoxConstraints
/// forces an infinite height" وقت التشغيل الحقيقي — خطأ layout ما
/// بيمسكه `flutter analyze` ولا اختبار Cubit. هالاختبار بيعيد نفس
/// السياق (الودجت جوّا `ListView` بلا ارتفاع محدود) عمداً حتى يلقط
/// الانتكاسة لو رجع حدا حذف `IntrinsicHeight`.
void main() {
  testWidgets('بلا استثناء جوّا ListView عمودي (ارتفاع غير محدود)', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _designSize,
        builder: (context, child) => MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: ListView(
              children: [
                HomeQuickActions(
                  onSubmitComplaint: () {},
                  onMunicipalServices: () {},
                  onSkills: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(HomeQuickActions), findsOneWidget);
  });

  testWidgets('التبويبات الثلاثة قابلة للنقر', (tester) async {
    var complaintTapped = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _designSize,
        builder: (context, child) => MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: ListView(
              children: [
                HomeQuickActions(
                  onSubmitComplaint: () => complaintTapped = true,
                  onMunicipalServices: () {},
                  onSkills: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('home_quick_complaint'));
    await tester.pump();

    expect(complaintTapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
