import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/design_system/widgets/image_source_sheet.dart';

const _designSize = Size(375, 812);

/// بتفتح الورقة وبترجّع دالة `result()` لقراءة الاختيار بعد ما يصير.
///
/// حجم شاشة حقيقي إلزامي هون: سطح الاختبار الافتراضي (800×600 مقسوم على
/// الـ modal) أضيق من محتوى الورقة فبيطلع RenderFlex overflow زائف —
/// نفس الحل المستخدم بـ`profile_content_test.dart`.
Future<ImageSourceAction? Function()> _openSheet(
  WidgetTester tester, {
  bool showRemoveOption = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _designSize;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  ImageSourceAction? result;
  var completed = false;

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showImageSourceSheet(
                  context,
                  // نصوص خام لا `.tr()`: الاختبار بيدوّر على المفتاح
                  // نفسه — راجع «الاختبارات بتفحص المفتاح لا النص»
                  // بـ`CLAUDE.md`.
                  title: 'avatar_sheet_title',
                  cameraLabel: 'avatar_source_camera',
                  galleryLabel: 'avatar_source_gallery',
                  showRemoveOption: showRemoveOption,
                  removeLabel: 'avatar_source_remove',
                );
                completed = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  return () {
    expect(completed, isTrue, reason: 'الورقة لسه مفتوحة — لازم تنسكّر أول');
    return result;
  };
}

void main() {
  testWidgets('بلا صورة حالية: بلا خيار إزالة', (tester) async {
    await _openSheet(tester, showRemoveOption: false);

    expect(find.text('avatar_source_camera'), findsOneWidget);
    expect(find.text('avatar_source_gallery'), findsOneWidget);
    expect(find.text('avatar_source_remove'), findsNothing);
  });

  testWidgets('مع صورة حالية: خيار الإزالة بيظهر', (tester) async {
    await _openSheet(tester, showRemoveOption: true);

    expect(find.text('avatar_source_remove'), findsOneWidget);
  });

  testWidgets('اختيار الكاميرا بيرجّع camera', (tester) async {
    final result = await _openSheet(tester);

    await tester.tap(find.text('avatar_source_camera'));
    await tester.pumpAndSettle();

    expect(result(), ImageSourceAction.camera);
  });

  testWidgets('اختيار المعرض بيرجّع gallery', (tester) async {
    final result = await _openSheet(tester);

    await tester.tap(find.text('avatar_source_gallery'));
    await tester.pumpAndSettle();

    expect(result(), ImageSourceAction.gallery);
  });

  testWidgets('اختيار الإزالة بيرجّع remove', (tester) async {
    final result = await _openSheet(tester, showRemoveOption: true);

    await tester.tap(find.text('avatar_source_remove'));
    await tester.pumpAndSettle();

    expect(result(), ImageSourceAction.remove);
  });

  testWidgets('السكر بلا اختيار بيرجّع null', (tester) async {
    final result = await _openSheet(tester);

    // الضغط برّا الورقة (المنطقة العاتمة فوقها) بيسكّرها بلا اختيار.
    await tester.tapAt(const Offset(200, 50));
    await tester.pumpAndSettle();

    expect(result(), isNull);
  });
}
