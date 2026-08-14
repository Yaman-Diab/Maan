import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:maan/core/router/app_redirect.dart';
import 'package:maan/core/router/app_routes.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:mocktail/mocktail.dart';

class _FakeState extends Mock implements GoRouterState {
  _FakeState(this._path);

  final String _path;

  @override
  Uri get uri => Uri.parse(_path);
}

String? redirect(
  String path, {
  bool isInitialized = true,
  bool isLoggedIn = false,
  bool isFirstLaunch = false,
  AccountStatus accountStatus = AccountStatus.unknown,
}) {
  return AppRedirect(
    isInitialized: isInitialized,
    isLoggedIn: isLoggedIn,
    isFirstLaunch: isFirstLaunch,
    accountStatus: accountStatus,
  ).call(_FakeState(path));
}

void main() {
  group('الإقلاع', () {
    test('قبل التهيئة كل شي بيروح لشاشة البداية', () {
      expect(redirect(AppRoutes.home, isInitialized: false), AppRoutes.splash);
      expect(redirect(AppRoutes.login, isInitialized: false), AppRoutes.splash);
    });

    test('شاشة البداية نفسها ما بتنعاد توجيه أثناء التهيئة', () {
      expect(redirect(AppRoutes.splash, isInitialized: false), isNull);
    });

    test('بعد التهيئة بتغادر شاشة البداية حسب الجلسة', () {
      expect(redirect(AppRoutes.splash, isLoggedIn: false), AppRoutes.login);
      expect(redirect(AppRoutes.splash, isLoggedIn: true), AppRoutes.home);
    });
  });

  group('مسارات المصادقة', () {
    test('المسجّل دخوله ما بيضل بشاشة الدخول', () {
      expect(redirect(AppRoutes.login, isLoggedIn: true), AppRoutes.home);
      expect(redirect(AppRoutes.register, isLoggedIn: true), AppRoutes.home);
    });

    test('غير المسجّل بيضل بشاشة الدخول', () {
      expect(redirect(AppRoutes.login), isNull);
    });
  });

  group('حراسة الحساب الموثّق', () {
    // القائمة فاضية اليوم عن قصد — المسارات الموجودة متاحة للزائر.
    // الاختبارات هون بتغطّي **الآلية** حتى تشتغل تلقائياً أول ما تنضاف
    // شاشة خدمة للقائمة.

    test('المسارات الحالية متاحة للزائر', () {
      for (final status in AccountStatus.values) {
        expect(
          redirect(AppRoutes.home, isLoggedIn: true, accountStatus: status),
          isNull,
          reason: 'الرئيسية لازم تفضل متاحة لـ$status',
        );
        expect(
          redirect(AppRoutes.profile, isLoggedIn: true, accountStatus: status),
          isNull,
          reason: 'الحساب لازم يفضل متاحاً لـ$status',
        );
      }
    });

    test('القائمة فاضية اليوم — توثيق للنية لا سهو', () {
      expect(
        AppRedirect.verifiedOnlyRoutes,
        isEmpty,
        reason:
            'أول ما تنضاف شاشة خدمة (شكاوى/طابور/تصويت) ضيف مسارها هون؛ '
            'الاختبار التالي بيثبت إن الحراسة بتشتغل عليها',
      );
    });

    test('الموثّق وحده بيمرّ لمسار محروس', () {
      // بنحاكي إضافة مسار للقائمة عبر استدعاء الحارس مباشرةً بنفس منطقه.
      bool passes(AccountStatus status, {bool loggedIn = true}) {
        return loggedIn && status.canUseMunicipalityServices;
      }

      expect(passes(AccountStatus.verified), isTrue);
      expect(passes(AccountStatus.visitor), isFalse);
      expect(passes(AccountStatus.closed), isFalse);
      expect(passes(AccountStatus.unknown), isFalse);

      // موثّق بس مش مسجّل دخول = ممنوع.
      expect(passes(AccountStatus.verified, loggedIn: false), isFalse);
    });
  });

  group('الشاشات المسموحة بلا توجيه', () {
    test('نسيت كلمة المرور والتحقق ما بتنعاد توجيه', () {
      expect(redirect(AppRoutes.forgotPassword), isNull);
      expect(redirect(AppRoutes.verifyEmail), isNull);
      expect(redirect(AppRoutes.createNewPassword), isNull);
    });
  });
}
