import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';

const _designSize = Size(375, 812);

Future<TextEditingController> _pump(
  WidgetTester tester, {
  int? maxLength,
  bool digitsOnly = false,
}) async {
  final controller = TextEditingController();

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: CustomTextFormField(
            controller: controller,
            keyBoardType: TextInputType.text,
            validationMessage: (_) => null,
            maxLength: maxLength,
            digitsOnly: digitsOnly,
          ),
        ),
      ),
    ),
  );

  return controller;
}

void main() {
  testWidgets('بلا maxLength بتقبل أي طول وما بيظهر عدّاد', (tester) async {
    final controller = await _pump(tester);

    await tester.enterText(find.byType(TextFormField), 'a' * 500);

    expect(controller.text, hasLength(500));
    expect(find.textContaining('/'), findsNothing);
  });

  testWidgets('maxLength بيمنع تجاوز الحد بلا رسالة خطأ', (tester) async {
    final controller = await _pump(tester, maxLength: 5);

    await tester.enterText(find.byType(TextFormField), 'abcdefghij');

    // `LengthLimitingTextInputFormatter` بيقصّ عند الكتابة نفسها —
    // القيمة بالـ controller ما بتتجاوز الحد إطلاقاً.
    expect(controller.text, 'abcde');
  });

  testWidgets('maxLength ما بيرسم عدّاد Flutter الافتراضي', (tester) async {
    await _pump(tester, maxLength: 50);

    // التصميم ما فيه عنصر عدّاد أحرف — `counterText: ''` لازم يلغيه.
    expect(find.textContaining('/50'), findsNothing);
  });

  testWidgets('digitsOnly بيرفض الحروف وبيقبل الأرقام بس', (tester) async {
    final controller = await _pump(tester, digitsOnly: true);

    await tester.enterText(find.byType(TextFormField), 'a1b2c3');

    expect(controller.text, '123');
  });

  testWidgets('digitsOnly مع maxLength بيطبّق الاثنين مع بعض', (tester) async {
    final controller = await _pump(tester, digitsOnly: true, maxLength: 3);

    await tester.enterText(find.byType(TextFormField), 'a1b2c3d4e5');

    expect(controller.text, '123');
  });
}
