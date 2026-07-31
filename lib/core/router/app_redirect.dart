// -------------------------
// App Redirect
// -------------------------

import 'package:go_router/go_router.dart';

import '../session/account_status.dart';
import 'app_routes.dart';

class AppRedirect {
  const AppRedirect({
    required this.isInitialized,
    required this.isLoggedIn,
    this.isFirstLaunch = false,
    this.accountStatus = AccountStatus.unknown,
  });

  final bool isInitialized;
  final bool isLoggedIn;
  final bool isFirstLaunch;

  /// حالة الحساب على السيرفر — بتمنع غير الموثّق من مسارات الخدمات.
  final AccountStatus accountStatus;

  /// المسارات اللي بتتطلب حساباً موثّقاً.
  ///
  /// `PROJECT_CONTEXT` بينص إن الشكاوى والبلاغات والتصويت والتبرع
  /// والتطوع والطابور كلها ممنوعة قبل التوثيق العام.
  ///
  /// **فاضية اليوم عن قصد**: المسارات الموجودة (`home`, `profile`)
  /// متاحة للزائر. أول ما تنضاف شاشة خدمة، ضيف مسارها هون وبتشتغل
  /// الحراسة تلقائياً — الاختبارات بتغطي الآلية أصلاً.
  static const Set<String> verifiedOnlyRoutes = {};

  bool get _hasVerifiedAccount =>
      isLoggedIn && accountStatus.canUseMunicipalityServices;

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

    // -------------------------
    // Verified-Only Services
    // -------------------------
    //
    // بيرجّع للرئيسية لا لتسجيل الدخول: المستخدم داخل فعلاً، بس حسابه
    // لسه ما توثّق. رميه على شاشة الدخول بيبان كأنه انطرد.

    if (verifiedOnlyRoutes.contains(path) && !_hasVerifiedAccount) {
      return AppRoutes.home;
    }

    return null;
  }
}
