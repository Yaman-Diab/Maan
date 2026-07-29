// -------------------------
// Main
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme.dart';
import 'package:maan/features/auth/cubit/privacy_checkbox_cubit.dart';

import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/session/app_session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // -------------------------
  // Easy Localization Init
  // -------------------------

  await EasyLocalization.ensureInitialized();

  // -------------------------
  // Dependency Injection
  // -------------------------

  await setupServiceLocator();

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
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<PrivacyCheckboxCubit>(
                create: (_) => PrivacyCheckboxCubit(),
              ),
            ],
            child: MaanApp(appRouter: appRouter),
          );
        },
      ),
    ),
  );

  await sessionController.bootstrap();
}

class MaanApp extends StatelessWidget {
  const MaanApp({super.key, required this.appRouter});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Maan ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerConfig: appRouter.router,
    );
  }
}
