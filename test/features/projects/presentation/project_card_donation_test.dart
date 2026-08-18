import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/design_system/widgets/app_progress_bar.dart';
import 'package:maan/features/projects/domain/entities/municipal_project.dart';
import 'package:maan/features/projects/domain/entities/project_donation_stats.dart';
import 'package:maan/features/projects/presentation/projects/widgets/project_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ⚠️ ماونت واحد لـ`EasyLocalization` بكل ملف اختبار — السيناريوهات
/// بتنفّذ تسلسلياً جوّا `testWidgets` وحيد. راجع CLAUDE.md › الترجمة.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // `EasyLocalization` بتقرأ اللغة المحفوظة من SharedPreferences —
    // بلا هالمزيّف بترمي `MissingPluginException`.
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Widget wrap(MunicipalProject project) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/translations',
        startLocale: const Locale('ar'),
        child: Builder(
          builder: (context) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            theme: AppTheme.light(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProjectCard(project: project, canParticipate: true),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('شريط التبرعات — الحالات الثلاث', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // ── ١. في هدف: شريط تقدّم + نسبة ظاهرين ──
    await tester.pumpWidget(
      wrap(
        const MunicipalProject(
          id: 1,
          title: 'مشروع',
          requiresDonations: true,
          donationStats: ProjectDonationStats(
            totalDonated: 650000,
            donationTarget: 1000000,
            remainingAmount: 350000,
            donationPercentage: 65,
            numberOfDonors: 42,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AppProgressBar), findsOneWidget);
    expect(find.text('65%'), findsOneWidget);
    // المبالغ بفواصل آلاف لاتينية.
    expect(find.textContaining('650,000'), findsOneWidget);

    // ── ٢. بلا هدف (المشروع بلا ميزانية): بلا شريط ولا نسبة ──
    await tester.pumpWidget(
      wrap(
        const MunicipalProject(
          id: 2,
          title: 'مشروع',
          requiresDonations: true,
          donationStats: ProjectDonationStats(
            totalDonated: 5000,
            numberOfDonors: 3,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // ⚠️ الحافة الأهم: شريط تقدّم بلا هدف كان رح يبان فاضياً دائماً
    // (النسبة بترجع 0 من الباك اند) وكأن ما حدا تبرّع.
    expect(find.byType(AppProgressBar), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('5,000'), findsOneWidget);

    // ── ٣. بلا إحصائيات أصلاً (فشل جلبها): القسم كامل بيختفي ──
    await tester.pumpWidget(
      wrap(
        const MunicipalProject(id: 3, title: 'مشروع', requiresDonations: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AppProgressBar), findsNothing);

    // ── ٤. requiresVolunteers/requiresDonations الافتراضيان false
    // (فشل جلب GET /api/project/{id} مثلاً) → القسم كامل بيختفي ──
    await tester.pumpWidget(
      wrap(const MunicipalProject(id: 4, title: 'مشروع بلا تفاصيل بعد')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('تطوّع'), findsNothing);
    expect(find.text('تبرّع'), findsNothing);

    // ── ٥. requiresVolunteers/requiresDonations true (من التفاصيل
    // المدموجة) → الزرّان ظاهرين ──
    await tester.pumpWidget(
      wrap(
        const MunicipalProject(
          id: 5,
          title: 'مشروع بتفاصيل كاملة',
          requiresVolunteers: true,
          volunteersNeeded: 7,
          requiresDonations: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('تطوّع'), findsOneWidget);
    expect(find.text('تبرّع'), findsOneWidget);
  });
}
