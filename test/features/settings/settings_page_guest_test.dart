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
import 'package:maan/core/storage/secure_storage_service.dart';
import 'package:maan/core/storage/settings_storage_service.dart';
import 'package:maan/features/settings/presentation/pages/settings_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSettingsStorage extends Mock implements SettingsStorageService {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _MockPermissionService extends Mock implements AppPermissionService {}

const _designSize = Size(375, 812);

/// بملف منفصل عن `settings_page_test.dart` عمداً — راجع تعليق `_pump`
/// هناك: أي ماونت ثانٍ لـ`EasyLocalization` **بنفس ملف الاختبار**
/// بيرجّع شجرة فاضية. هالسيناريو محتاج جلسة زائر من البداية (ما فينا
/// نبدّلها بعد الماونت بنفس الاختبار الكبير)، فبده ماونت أول مستقل.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('قسم الحساب ما بينعرض للزائر إطلاقاً', (tester) async {
    final storage = _MockSecureStorage();
    when(() => storage.isLoggedIn()).thenAnswer((_) async => false);
    when(() => storage.isGuest()).thenAnswer((_) async => true);
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

    final settingsStorage = _MockSettingsStorage();
    when(() => settingsStorage.readThemeMode()).thenReturn(null);
    when(() => settingsStorage.readTextScale()).thenReturn(null);
    when(() => settingsStorage.saveThemeMode(any())).thenAnswer((_) async {});
    when(() => settingsStorage.saveTextScale(any())).thenAnswer((_) async {});
    final settingsCubit = SettingsCubit(settingsStorage)..load();

    await sl.reset();
    sl.registerLazySingleton<AppSessionController>(() => session);
    sl.registerLazySingleton<AppPermissionService>(
      () => _MockPermissionService(),
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

    expect(find.text('Account'), findsNothing);
    expect(find.text('Log out'), findsNothing);
    expect(find.text('Delete Account'), findsNothing);

    // بالمقابل التفضيلات العامة (مفيدة قبل تسجيل الدخول كمان) لازم تبيّن.
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Language'), findsWidgets);
  });
}
