import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/core/di/service_locator.dart';
import 'package:maan/core/permissions/app_permission_service.dart';
import 'package:maan/core/session/app_session_controller.dart';
import 'package:maan/core/settings/cubit/settings_cubit.dart';
import 'package:maan/core/settings/cubit/settings_state.dart';
import 'package:maan/core/storage/secure_storage_service.dart';
import 'package:maan/core/storage/settings_storage_service.dart';
import 'package:maan/features/settings/presentation/pages/settings_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSettingsStorage extends Mock implements SettingsStorageService {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _MockPermissionService extends Mock implements AppPermissionService {}

const _designSize = Size(375, 812);

/// جلسة مبنيّة على تخزين مزيّف — نفس نمط
/// `test/core/session/app_session_controller_test.dart`، مش عبر
/// `setupCoreDependencies()` الحقيقية لأنها بتلمس `flutter_secure_storage`
/// (قناة منصّة حقيقية غير متوفّرة بالاختبار).
Future<AppSessionController> _session({required bool loggedIn}) async {
  final storage = _MockSecureStorage();

  when(() => storage.isLoggedIn()).thenAnswer((_) async => loggedIn);
  when(() => storage.isGuest()).thenAnswer((_) async => !loggedIn);
  when(() => storage.getAccountStatus()).thenAnswer((_) async => null);
  when(() => storage.setGuest(any())).thenAnswer((_) async {});
  when(() => storage.saveAccountStatus(any())).thenAnswer((_) async {});
  when(
    () => storage.clearSession(
      keepGuestFlag: any(named: 'keepGuestFlag'),
      keepVisitorId: any(named: 'keepVisitorId'),
    ),
  ).thenAnswer((_) async {});

  final session = AppSessionController(storage: storage);
  await session.bootstrap();

  return session;
}

SettingsCubit _settingsCubit() {
  final storage = _MockSettingsStorage();

  when(() => storage.readThemeMode()).thenReturn(null);
  when(() => storage.readTextScale()).thenReturn(null);
  when(() => storage.saveThemeMode(any())).thenAnswer((_) async {});
  when(() => storage.saveTextScale(any())).thenAnswer((_) async {});

  return SettingsCubit(storage)..load();
}

/// ⚠️ حاسم لموثوقية هالملف: `EasyLocalization` بينحمّل مرّة وحدة فقط
/// بشكل موثوق لكل عملية اختبار — تأكّدنا تجريبياً إن أي `pumpWidget`
/// ثانٍ لودجت `EasyLocalization` جديدة **داخل نفس ملف الاختبار** بيرجّع
/// شجرة فاضية تماماً (صفر ودجتات) بلا أي استثناء ظاهر، على الأغلب حالة
/// سباق بكاش الودجت الداخلي للحزمة عبر عمليات pump متتالية بنفس الـ
/// isolate. الحل: ماونت واحد بس لكل ملف اختبار — كل السيناريوهات
/// المسجَّل دخولها هون بتنفّذ **تسلسلياً جوّا اختبار وحيد**، وسيناريو
/// الزائر (يحتاج ماونت مختلف من البداية) بملف منفصل
/// (`settings_page_guest_test.dart`) حتى ياخد الماونت الأول الموثوق
/// بعملية الاختبار تبعه.
Future<SettingsCubit> _pump(
  WidgetTester tester, {
  required AppSessionController session,
  AppPermissionService? permissionService,
}) async {
  final settingsCubit = _settingsCubit();

  await sl.reset();
  sl.registerLazySingleton<AppSessionController>(() => session);
  sl.registerLazySingleton<AppPermissionService>(
    () => permissionService ?? _MockPermissionService(),
  );

  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _designSize;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    settingsCubit.close();
    sl.reset();
  });

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: ScreenUtilInit(
        designSize: _designSize,
        builder: (context, child) => BlocProvider<SettingsCubit>.value(
          value: settingsCubit,
          child: MaterialApp(
            theme: AppTheme.light(),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const SettingsPage(),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  return settingsCubit;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // `EasyLocalization.ensureInitialized` بيقرأ/يكتب اللغة المحفوظة عبر
    // shared_preferences داخلياً — بلا قناة منصّة مزيّفة بيفشل بـ
    // `MissingPluginException` قبل ما يوصل لأي اختبار.
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'شاشة الإعدادات — مسجّل دخوله: كل السيناريوهات بماونت واحد',
    (tester) async {
      final session = await _session(loggedIn: true);
      final permissionService = _MockPermissionService();
      when(
        () => permissionService.openSystemSettings(),
      ).thenAnswer((_) async {});

      final cubit = await _pump(
        tester,
        session: session,
        permissionService: permissionService,
      );

      // -------------------------
      // المظهر
      // -------------------------
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(cubit.state.themeMode, ThemeMode.dark);

      await tester.tap(find.text('A+'));
      await tester.pumpAndSettle();
      expect(cubit.state.textScale, AppTextScale.large);

      // -------------------------
      // الخصوصية والأذونات
      // -------------------------
      await tester.ensureVisible(find.text('Location Access'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Location Access'));
      await tester.pumpAndSettle();
      verify(() => permissionService.openSystemSettings()).called(1);

      await tester.ensureVisible(find.text('Camera & Photos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Camera & Photos'));
      await tester.pumpAndSettle();
      verify(() => permissionService.openSystemSettings()).called(1);

      // -------------------------
      // حول التطبيق — روابط بلا وجهة مؤكّدة بعد
      // -------------------------
      await tester.ensureVisible(find.text('Contact Support'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Contact Support'));
      await tester.pumpAndSettle();
      expect(find.text('Coming soon'), findsOneWidget);

      // -------------------------
      // الحساب — حذف (ما في endpoint حقيقي لسه)
      // -------------------------
      await tester.ensureVisible(find.text('Delete Account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();
      expect(find.text('Delete your account?'), findsOneWidget);

      await tester.tap(find.text('Delete Account').last);
      await tester.pumpAndSettle();
      expect(
        find.text("Account deletion isn't available yet. Please contact support."),
        findsOneWidget,
      );
      // ⚠️ ما في endpoint حقيقي — الحساب يضل مسجّل دخوله، ما انحذف شي.
      expect(session.isLoggedIn, isTrue);

      // -------------------------
      // الحساب — إلغاء ورقة الخروج
      // -------------------------
      await tester.ensureVisible(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(find.text("Log out of Ma'an?"), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(session.isLoggedIn, isTrue);

      // -------------------------
      // الحساب — تسجيل خروج فعلي (آخر خطوة: بيغيّر حالة الجلسة)
      // -------------------------
      await tester.ensureVisible(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(find.text("Log out of Ma'an?"), findsOneWidget);

      // زر التأكيد جوّا الورقة نفس نص الصف («Log out»)، فبنلقط آخر
      // واحد (الأحدث بالشجرة = جوّا الورقة).
      await tester.tap(find.text('Log out').last);
      await tester.pumpAndSettle();
      expect(session.isLoggedIn, isFalse);

      // قسم الحساب بينخفي فوراً بعد الخروج — الصفحة نفسها ضلّت مفتوحة.
      expect(find.text('Account'), findsNothing);
      expect(find.text('Log out'), findsNothing);
      expect(find.text('Delete Account'), findsNothing);
    },
  );
}
