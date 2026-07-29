// -------------------------
// App Redirect
// -------------------------

import 'package:go_router/go_router.dart';

import 'app_routes.dart';

class AppRedirect {
  const AppRedirect({
    required this.isInitialized,
    required this.isLoggedIn,
    this.isFirstLaunch = false,
  });

  final bool isInitialized;
  final bool isLoggedIn;
  final bool isFirstLaunch;

  String? call(GoRouterState state) {
    final path = state.uri.path;

    final isSplash = path == AppRoutes.splash;
    final isOnboarding = path == AppRoutes.onboarding;

    final isAuthRoute = path == AppRoutes.login || path == AppRoutes.register;

    // -------------------------
    // App Still Loading
    // -------------------------

    if (!isInitialized) {
      return isSplash ? null : AppRoutes.splash;
    }

    // -------------------------
    // First Launch
    // -------------------------

    if (isFirstLaunch && !isOnboarding) {
      return AppRoutes.onboarding;
    }

    if (!isFirstLaunch && isOnboarding) {
      return AppRoutes.home;
    }

    // -------------------------
    // Logged-in User Should Not Stay In Auth Pages
    // -------------------------

    if (isLoggedIn && isAuthRoute) {
      final from = state.uri.queryParameters['from'];

      if (from != null && from.isNotEmpty) {
        return from;
      }

      return AppRoutes.home;
    }

    // -------------------------
    // Splash Finished
    // -------------------------

    if (isSplash) {
      return isLoggedIn ? AppRoutes.home : AppRoutes.login;
    }

    return null;
  }
}
