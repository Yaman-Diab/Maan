import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/design_system/widgets/app_card.dart';
import 'package:maan/features/verification/presentation/verification/widgets/verification_skeleton.dart';

const _designSize = Size(375, 812);

void main() {
  // ⚠️ `Bone`/`Skeletonizer` عوامّ (`factory`) بيرجّعوا أصناف خاصة
  // فعلياً (`_Bone`/`_Skeletonizer`)، فـ`find.byType` عليهم ما بيلاقي
  // شي — تأكّدنا تجريبياً. الفحص هون عبر `AppCard` (ودجت عام حقيقي)
  // وغياب أي استثناء بدل نوع ودجت الحزمة الداخلي.
  testWidgets('بتبني بلا استثناء وبتعرض شكل عام بثلاث بطاقات', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: _designSize,
        builder: (context, child) => MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: VerificationSkeleton()),
        ),
      ),
    );

    // `pumpAndSettle` بتعلّق مع تأثير الوميض اللانهائي.
    await tester.pump();

    expect(tester.takeException(), isNull);

    // بطاقة البيانات الشخصية + بطاقة الرقم الوطني + بطاقة الوثيقة.
    expect(find.byType(AppCard), findsNWidgets(3));
  });
}
