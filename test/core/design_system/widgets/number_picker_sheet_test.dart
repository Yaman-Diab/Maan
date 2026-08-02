import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/design_system/widgets/number_picker_sheet.dart';

const _designSize = Size(375, 812);

/// حارس بيفرّق «رجعت null» عن «ما رجعت بعد».
const _notCalled = -999;

class _Host extends StatelessWidget {
  const _Host({required this.onResult, required this.initialValue});

  final ValueChanged<int?> onResult;
  final int initialValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await showNumberPickerSheet(
              context: context,
              title: 'اختر اليوم',
              values: List.generate(28, (index) => index + 1),
              initialValue: initialValue,
            );

            onResult(result);
          },
          child: const Text('open'),
        ),
      ),
    );
  }
}

Future<void> _openSheet(
  WidgetTester tester, {
  required ValueChanged<int?> onResult,
  int initialValue = 1,
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
        home: _Host(onResult: onResult, initialValue: initialValue),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

/// سحب العجلة نفسها لعنصرين تقريباً.
Future<void> _scrollWheel(WidgetTester tester) async {
  await tester.drag(find.byType(ListWheelScrollView), const Offset(0, -100));
  await tester.pumpAndSettle();
}

/// نقرة بأعلى الشاشة — برّا الورقة المثبّتة بالأسفل.
Future<void> _tapOutside(WidgetTester tester) async {
  await tester.tapAt(const Offset(200, 40));
  await tester.pumpAndSettle();
}

void main() {
  group('الخروج بلا زر — بيقبل فقط إذا تحرّكت العجلة', () {
    testWidgets('نقرة برّا بعد السحب بتقبل القيمة الجديدة', (tester) async {
      int? result = _notCalled;

      await _openSheet(tester, onResult: (value) => result = value);
      await _scrollWheel(tester);
      await _tapOutside(tester);

      expect(result, isNotNull);
      expect(result, isNot(1));
    });

    testWidgets('نقرة برّا بلا سحب ما بتغيّر شي — حتى لو الحقل فاضي', (
      tester,
    ) async {
      int? result = _notCalled;

      await _openSheet(tester, onResult: (value) => result = value);
      await _tapOutside(tester);

      // `null` = «لا تغيير»، فحقل فاضي بيضل فاضي بدل ما نخترع له قيمة.
      expect(result, isNull);
    });

    testWidgets('سحب الورقة للأسفل بيتصرّف متل النقرة برّا بالضبط', (
      tester,
    ) async {
      // هاي الإيماءة بتمرّ بمسار مختلف بـFlutter (`BottomSheet.onClosing`
      // بينادي `Navigator.pop` المباشر فبيتجاوز `PopScope`)، فلازم
      // تنفحص لحالها — بلاها كانت بتلغي بصمت بينما النقرة برّا بتقبل.
      int? result = _notCalled;

      await _openSheet(tester, onResult: (value) => result = value);
      await _scrollWheel(tester);

      // السحب من ترويسة الورقة لا من العجلة — العجلة بتبلع الإيماءة
      // وبتتمرّر هي بدل ما تنسحب الورقة.
      await tester.fling(find.text('اختر اليوم'), const Offset(0, 600), 2000);
      await tester.pumpAndSettle();

      expect(result, isNot(_notCalled), reason: 'الورقة لازم تكون سكّرت');
      expect(result, isNotNull);
      expect(result, isNot(1));
    });
  });

  group('الأزرار الصريحة', () {
    testWidgets('«إلغاء» بيرجّع null حتى بعد السحب', (tester) async {
      int? result = _notCalled;

      await _openSheet(tester, onResult: (value) => result = value);
      await _scrollWheel(tester);

      await tester.tap(find.text('cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('«تم» بيرجّع القيمة الجديدة بعد السحب', (tester) async {
      int? result = _notCalled;

      await _openSheet(tester, onResult: (value) => result = value);
      await _scrollWheel(tester);

      await tester.tap(find.text('done'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result, isNot(1));
    });

    testWidgets('«تم» بلا سحب بيأكّد القيمة المعروضة — تأكيد صريح', (
      tester,
    ) async {
      int? result = _notCalled;

      await _openSheet(tester, onResult: (value) => result = value, initialValue: 7);

      await tester.tap(find.text('done'));
      await tester.pumpAndSettle();

      expect(result, 7);
    });
  });
}
