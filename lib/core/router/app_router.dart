// -------------------------
// App Router
// -------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maan/features/auth/create_new_password/create_new_password_page.dart';
import 'package:maan/features/auth/forgot_password/forgot_password_page.dart';
import 'package:maan/features/auth/presentation/login/pages/login_page.dart';
import 'package:maan/features/auth/sign_up/sign_up_page.dart';
import 'package:maan/features/auth/verify_email/verify_email_page.dart';
import '../../features/app_shell/app_shell_page.dart';
import 'app_redirect.dart';
import 'app_routes.dart';

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
          return const _TempPage(
            title: 'Splash',
            description: 'Loading...',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) {
          return SignUpPage();
        },
      ),
      // ------------------------- هذا مؤقت لتجربه صفحه التحقق من الايميل
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) {
          return const VerifyEmailPage(email: 'Omar@Gmail.com');
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) {
          return ForgotPasswordPage();
        },
      ),
      GoRoute(
        path: AppRoutes.createNewPassword,
        builder: (context, state) {
          return CreateNewPasswordPage();
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
                  return const _TempPage(
                    title: 'الرئيسية',
                    description: 'Home Page',
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
                  return const _TempPage(
                    title: 'حسابي',
                    description: 'Profile Page',
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
        title: 'Page Not Found',
        description: state.error?.toString() ?? 'Route not found',
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
