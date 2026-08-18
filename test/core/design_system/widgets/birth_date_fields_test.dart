import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/design_system/widgets/birth_date_fields.dart';
import 'package:maan/core/domain/birth_date.dart';

const _designSize = Size(375, 812);

/// بتغطي الشكلين اللي بيستخدموا الودجت المشتركة: التسجيل (بلا قيم،
/// مفعّلة) وتعديل الهوية (بقيم، وممكن تكون مقفولة).
Future<void> _pump(
  WidgetTester tester, {
  int? day,
  int? month,
  int? year,
  BirthDateError? error,
  bool enabled = true,
  required List<int> picked,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _designSize;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final dayController = TextEditingController(text: day?.toString() ?? '');
  final monthController = TextEditingController(text: month?.toString() ?? '');
  final yearController = TextEditingController(text: year?.toString() ?? '');

  addTearDown(() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
  });

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: BirthDateFields(
            label: 'your_birthday',
            day: day,
            month: month,
            year: year,
            error: error,
            enabled: enabled,
            dayController: dayController,
            monthController: monthController,
            yearController: yearController,
            onDayPicked: picked.add,
            onMonthPicked: picked.add,
            onYearPicked: picked.add,
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('بترسم العنوان والحقول الثلاثة', (tester) async {
    await _pump(tester, picked: []);

    expect(find.text('your_birthday'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNWidgets(3));
  });

  testWidgets('خطأ التاريخ بينعرض مرة وحدة تحت الحقول لا تحت كل حقل', (
    tester,
  ) async {
    await _pump(tester, error: BirthDateError.tooYoung, picked: []);

    // الرسالة بتنبني من مفتاح ترجمة، وبلا تهيئة بيرجع المفتاح نفسه.
    expect(find.text('birthday_too_young'), findsOneWidget);
  });

  testWidgets('بلا خطأ ما بينعرض ولا نص خطأ', (tester) async {
    await _pump(tester, picked: []);

    expect(find.text('birthday_too_young'), findsNothing);
    expect(find.text('birthday_required'), findsNothing);
  });

  group('حالة القفل — تعديل الهوية لحساب موثّق', () {
    testWidgets('بتخفي سهم الاختيار', (tester) async {
      await _pump(
        tester,
        day: 12,
        month: 10,
        year: 1998,
        enabled: false,
        picked: [],
      );

      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
    });

    testWidgets('الضغط ما بيفتح العجلة', (tester) async {
      final picked = <int>[];

      await _pump(
        tester,
        day: 12,
        month: 10,
        year: 1998,
        enabled: false,
        picked: picked,
      );

      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();

      expect(find.text('select_day'), findsNothing);
      expect(picked, isEmpty);
    });
  });

  group('فتح العجلة', () {
    testWidgets('الضغط على حقل اليوم بيفتح عجلة اليوم', (tester) async {
      await _pump(tester, day: 12, month: 10, year: 1998, picked: []);

      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();

      expect(find.text('select_day'), findsOneWidget);
    });

    testWidgets('حقل فاضي (شاشة التسجيل) بيفتح العجلة كمان', (tester) async {
      // بشاشة التسجيل التاريخ بيبدأ `null` — لازم تشتغل بلا قيم أولية.
      await _pump(tester, picked: []);

      await tester.tap(find.byType(TextFormField).at(2));
      await tester.pumpAndSettle();

      expect(find.text('select_year'), findsOneWidget);
    });
  });
}
