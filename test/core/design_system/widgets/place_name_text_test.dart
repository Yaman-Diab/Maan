import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/widgets/place_name_text.dart';
import 'package:maan/core/di/service_locator.dart';
import 'package:maan/core/location/location_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocationService extends Mock implements LocationService {}

const _designSize = Size(375, 812);

/// ماونت واحد بس لـ`EasyLocalization` بهالملف — نفس قاعدة
/// `settings_page_test.dart` (ماونت ثانٍ بنفس الملف بيرجّع شجرة فاضية).
/// كل السيناريوهات هون بتنفّذ تسلسلياً جوّا اختبار وحيد لنفس السبب.
Future<void> _pump(
  WidgetTester tester, {
  required _MockLocationService locationService,
  double latitude = 33.5138,
  double longitude = 36.2760,
}) async {
  await sl.reset();
  sl.registerLazySingleton<LocationService>(() => locationService);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: ScreenUtilInit(
        designSize: _designSize,
        builder: (context, child) => MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: Scaffold(
            body: PlaceNameText(latitude: latitude, longitude: longitude),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('سيناريوهات PlaceNameText — ماونت وحيد بالملف', (tester) async {
    // ١) بلا استثناء وقت البناء الأول — هاد الباگ يلي صار فعلياً على
    // جهاز حقيقي: `context.locale` بـ`initState` بيرمي
    // `dependOnInheritedWidgetOfExactType... called before initState()
    // completed` لأنها استعلام InheritedWidget، وما بينلقط وقت
    // `initState` قيد التنفيذ. الإصلاح نقل الاستعلام لـ
    // `didChangeDependencies`.
    final resolvingService = _MockLocationService();
    when(
      () => resolvingService.describeCoordinates(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => 'المزة، دمشق');

    await _pump(tester, locationService: resolvingService);

    expect(tester.takeException(), isNull);
    expect(find.text('المزة، دمشق'), findsOneWidget);

    // ٢) فشل التحويل — الإحداثيات بتضل معروضة بدل ما تختفي.
    final failingService = _MockLocationService();
    when(
      () => failingService.describeCoordinates(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => null);

    // إحداثيات مختلفة عن السيناريو الأول — نفس شجرة الودجت (بلا مفتاح
    // مختلف) بتحدَّث عبر `didUpdateWidget` لا تنبني من جديد، فلازم
    // إحداثيات جديدة حتى ينعاد التحويل فعلياً بدل ما يضل الاسم القديم.
    await _pump(
      tester,
      locationService: failingService,
      latitude: 1.2345,
      longitude: 6.7890,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('1.2345, 6.7890'), findsOneWidget);
  });
}
