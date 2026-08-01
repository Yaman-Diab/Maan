// -------------------------
// Main
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme.dart';

import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/session/app_session_controller.dart';
import 'core/settings/cubit/settings_cubit.dart';
import 'core/settings/cubit/settings_state.dart';
import 'core/settings/widgets/text_scale_scope.dart';
import 'features/auth/auth_injection.dart';
import 'features/profile/profile_injection.dart';
import 'features/splash/presentation/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // -------------------------
  // Easy Localization Init
  // -------------------------

  await EasyLocalization.ensureInitialized();

  // -------------------------
  // Dependency Injection (Composition Root)
  // -------------------------

  await setupCoreDependencies();
  registerAuthDependencies(sl);
  registerProfileDependencies(sl);

  // -------------------------
  // Settings
  // -------------------------

  // بتنقرأ قبل runApp حتى يطلع أول إطار بالثيم المحفوظ مباشرةً،
  // بلا ومضة فاتح قبل الداكن.
  final settingsCubit = sl<SettingsCubit>()..load();

  // -------------------------
  // Session Controller
  // -------------------------

  final sessionController = sl<AppSessionController>();

  // -------------------------
  // Router
  // -------------------------

  final appRouter = AppRouter(
    refreshListenable: sessionController,
    isInitialized: () => sessionController.isInitialized,
    isLoggedIn: () => sessionController.isLoggedIn,
    isFirstLaunch: () => false,
    accountStatus: () => sessionController.accountStatus,
  );

  // -------------------------
  // Run App
  // -------------------------

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: BlocProvider<SettingsCubit>.value(
        value: settingsCubit,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          // الـ cubits الخاصة بالشاشات بتتزوّد من الصفحات نفسها عبر
          // BlocProvider + GetIt، فما في حاجة لمزوّدين عامّين هون.
          builder: (context, child) => MaanApp(appRouter: appRouter),
        ),
      ),
    ),
  );

  // الحدّ الأدنى بيجي من الشاشة نفسها لأنه مشتق من مدة حركتها.
  await sessionController.bootstrap(
    minimumDuration: SplashPage.minimumDuration,
  );
}

class MaanApp extends StatelessWidget {
  const MaanApp({super.key, required this.appRouter});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return MaterialApp.router(
          title: 'Maan ',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          routerConfig: appRouter.router,
          builder: (context, child) =>
              TextScaleScope(scale: settings.textScale, child: child),
        );
      },
    );
  }
}
