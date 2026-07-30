// -------------------------
// App Router
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maan/features/auth/presentation/create_new_password/pages/create_new_password_page.dart';
import 'package:maan/features/auth/presentation/forgot_password/pages/forgot_password_page.dart';
import 'package:maan/features/auth/presentation/login/pages/login_page.dart';
import 'package:maan/features/auth/presentation/sign_up/pages/sign_up_page.dart';
import 'package:maan/features/auth/presentation/verify_email/pages/verify_email_page.dart';
import 'package:maan/features/splash/presentation/pages/splash_page.dart';
import '../../features/app_shell/app_shell_page.dart';
import 'app_redirect.dart';
import 'app_routes.dart';
import 'route_args.dart';

class AppRouter {
  AppRouter({
 required this.refreshListenable,
 required this.isInitialized,
 required this.isLoggedIn,
 this.isFirstLaunch,
  });

  final Listenable refreshListenable;
  final bool Function() isInitialized;
  final bool Function() isLoggedIn;
  final bool Function()? isFirstLaunch;

  late final GoRouter router = GoRouter(
 initialLocation: AppRoutes.splash,
 refreshListenable: refreshListenable,
 debugLogDiagnostics: true,
 redirect: (context, state) {
   return AppRedirect(
     isInitialized: isInitialized(),
     isLoggedIn: isLoggedIn(),
     isFirstLaunch: isFirstLaunch?.call() ?? false,
   ).call(state);
 },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) {
          return const SplashPage();
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          return LoginPage(
            onSignUpTap: () => context.push(AppRoutes.register),
            onForgotPasswordTap: () => context.push(AppRoutes.forgotPassword),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) {
          return SignUpPage(
            // الـ backend بيبعت رمز تحقق بعد إنشاء الحساب.
            onSignedUp: (email) =>
                context.push(AppRoutes.verifyEmail, extra: email),
            onSignInTap: () => context.go(AppRoutes.login),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) {
          return VerifyEmailPage(
            email: state.extra as String? ?? '',
            onVerified: () => context.go(AppRoutes.login),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) {
          return ForgotPasswordPage(
            onCodeSent: (email) => context.push(
              AppRoutes.createNewPassword,
              extra: PasswordResetArgs(email: email),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.createNewPassword,
        builder: (context, state) {
          final args = state.extra as PasswordResetArgs?;

          return CreateNewPasswordPage(
            email: args?.email ?? '',
            code: args?.code ?? '',
            onPasswordChanged: () => context.go(AppRoutes.login),
          );
        },
      ),

      // -------------------------
      // Main App Shell
      // -------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) {
                  return _TempPage(
                    title: 'nav_home'.tr(),
                    description: 'home_page_placeholder'.tr(),
                  );
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) {
                  return _TempPage(
                    title: 'nav_profile'.tr(),
                    description: 'profile_page_placeholder'.tr(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      return _TempPage(
        title: 'page_not_found_title'.tr(),
        description: state.error?.toString() ?? 'route_not_found'.tr(),
      );
    },
  );
}

// -------------------------
// Temporary Page
// -------------------------

class _TempPage extends StatelessWidget {
  const _TempPage({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
