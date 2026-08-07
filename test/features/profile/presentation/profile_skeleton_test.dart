import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/features/profile/presentation/profile/widgets/profile_content.dart';
import 'package:maan/features/profile/presentation/profile/widgets/profile_skeleton.dart';

const _designSize = Size(375, 812);

void main() {
  // ⚠️ `Skeletonizer` widget عام (`factory`) بيرجّع صنف خاص (`_Skeletonizer`)
  // فعلياً، فـ`find.byType(Skeletonizer)` ما بيلاقي شي (`runtimeType`
  // مختلف عن النوع المطلوب) — تأكّدنا تجريبياً. الفحص هون بالتالي عبر
  // محتوى `ProfileContent` (اللي `ProfileSkeleton` بتغلّفه) لا عبر نوع
  // ودجت الحزمة الداخلي.
  testWidgets('بتبني بلا استثناء وبتغلّف ProfileContent ببيانات وهمية', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _designSize,
        builder: (context, child) => MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: ProfileSkeleton()),
        ),
      ),
    );

    // `pumpAndSettle` بتعلّق مع تأثير الوميض اللانهائي — نفس ملاحظة
    // `profile_content_test.dart` مع مؤشّر التقدّم.
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(ProfileContent), findsOneWidget);
    expect(find.text('Name Surname'), findsOneWidget);
  });
}
