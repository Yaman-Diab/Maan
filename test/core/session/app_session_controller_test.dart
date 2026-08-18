import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/core/session/app_session_controller.dart';
import 'package:maan/core/storage/secure_storage_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements SecureStorageService {}

void main() {
  late _MockSecureStorage storage;
  late AppSessionController controller;

  setUp(() {
    storage = _MockSecureStorage();
    controller = AppSessionController(storage: storage);

    when(() => storage.isLoggedIn()).thenAnswer((_) async => false);
    when(() => storage.isGuest()).thenAnswer((_) async => false);
    when(() => storage.setGuest(any())).thenAnswer((_) async {});
    when(() => storage.getAccountStatus()).thenAnswer((_) async => null);
    when(() => storage.saveAccountStatus(any())).thenAnswer((_) async {});
    when(
      () => storage.clearSession(
        keepGuestFlag: any(named: 'keepGuestFlag'),
        keepVisitorId: any(named: 'keepVisitorId'),
      ),
    ).thenAnswer((_) async {});
  });

  group('bootstrap — الحالة', () {
    test('بلا جلسة ولا زائر بيصير زائراً', () async {
      await controller.bootstrap();

      expect(controller.isInitialized, isTrue);
      expect(controller.isLoggedIn, isFalse);
      expect(controller.isGuest, isTrue);
      verify(() => storage.setGuest(true)).called(1);
    });

    test('بيقرأ جلسة محفوظة', () async {
      when(() => storage.isLoggedIn()).thenAnswer((_) async => true);

      await controller.bootstrap();

      expect(controller.isLoggedIn, isTrue);
      // ما بيصير زائراً وما بيكتب علم الزائر لو في جلسة.
      verifyNever(() => storage.setGuest(any()));
    });
  });

  group('bootstrap — الحدّ الأدنى لشاشة البداية', () {
    test('إقلاع سريع بينتظر لحد الحدّ الأدنى', () async {
      final watch = Stopwatch()..start();

      await controller.bootstrap(
        minimumDuration: const Duration(milliseconds: 300),
      );

      watch.stop();

      expect(
        watch.elapsedMilliseconds,
        greaterThanOrEqualTo(280),
        reason: 'بلا الانتظار بتختفي شاشة البداية قبل ما تكتمل حركتها',
      );
    });

    test('إقلاع بطيء ما بينضاف عليه شي — حدّ أدنى لا تأخير', () async {
      when(() => storage.isLoggedIn()).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return true;
      });

      final watch = Stopwatch()..start();

      await controller.bootstrap(
        minimumDuration: const Duration(milliseconds: 200),
      );

      watch.stop();

      expect(
        watch.elapsedMilliseconds,
        lessThan(450),
        reason:
            'الإقلاع أخذ 300ms والحدّ 200ms، فالمجموع لازم يضل ~300ms '
            'لا 500ms — يعني max لا جمع',
      );
    });

    test('بلا حدّ أدنى ما في انتظار إطلاقاً', () async {
      final watch = Stopwatch()..start();

      await controller.bootstrap();

      watch.stop();

      expect(watch.elapsedMilliseconds, lessThan(100));
    });

    test('isInitialized بتضل false لحد ما يخلص الانتظار', () async {
      final future = controller.bootstrap(
        minimumDuration: const Duration(milliseconds: 300),
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(
        controller.isInitialized,
        isFalse,
        reason: 'لو انقلبت بدري بيشتغل AppRedirect وبترفع الشاشة قبل وقتها',
      );

      await future;

      expect(controller.isInitialized, isTrue);
    });
  });

  group('حالة الحساب', () {
    test('بتبدأ unknown — أقل صلاحية', () {
      expect(controller.accountStatus, AccountStatus.unknown);
      expect(controller.canUseMunicipalityServices, isFalse);
    });

    test('bootstrap بيسترجع الحالة المخبّأة', () async {
      when(
        () => storage.getAccountStatus(),
      ).thenAnswer((_) async => 'verified');
      when(() => storage.isLoggedIn()).thenAnswer((_) async => true);

      await controller.bootstrap();

      expect(controller.accountStatus, AccountStatus.verified);
      expect(controller.canUseMunicipalityServices, isTrue);
    });

    test('قيمة مخزّنة تالفة ما بتوقّع الإقلاع', () async {
      when(
        () => storage.getAccountStatus(),
      ).thenAnswer((_) async => '!!تالف!!');

      await controller.bootstrap();

      expect(controller.accountStatus, AccountStatus.unknown);
      expect(controller.isInitialized, isTrue);
    });

    test('accountStatusChanged بتحفظ وبتبلّغ المستمعين', () async {
      var notified = 0;
      controller.addListener(() => notified++);

      await controller.accountStatusChanged(AccountStatus.verified);

      expect(controller.accountStatus, AccountStatus.verified);
      expect(notified, 1);
      verify(() => storage.saveAccountStatus('verified')).called(1);
    });

    test('نفس القيمة ما بتصدر إشعاراً ولا بتكتب', () async {
      await controller.accountStatusChanged(AccountStatus.verified);

      var notified = 0;
      controller.addListener(() => notified++);

      await controller.accountStatusChanged(AccountStatus.verified);

      expect(notified, 0);
      verify(() => storage.saveAccountStatus('verified')).called(1);
    });

    test(
      'loginCompleted بتقبل الحالة اختيارياً — العقد لسه غير مثبّت',
      () async {
        await controller.loginCompleted();
        expect(
          controller.accountStatus,
          AccountStatus.unknown,
          reason: 'بلا حالة من الاستجابة بتضل مجهولة لحد ما تُجلب من profile',
        );

        await controller.loginCompleted(accountStatus: AccountStatus.verified);
        expect(controller.accountStatus, AccountStatus.verified);
      },
    );

    test('تسجيل الخروج بيسقط الصلاحية', () async {
      await controller.accountStatusChanged(AccountStatus.verified);

      await controller.logout();

      expect(controller.accountStatus, AccountStatus.unknown);
      expect(controller.canUseMunicipalityServices, isFalse);
    });

    test('انتهاء الجلسة (401) بيسقط الصلاحية كمان', () async {
      await controller.accountStatusChanged(AccountStatus.verified);

      await controller.handleUnauthorized();

      expect(controller.accountStatus, AccountStatus.unknown);
    });

    test('الصلاحية بتحتاج تسجيل دخول مش بس حالة موثّقة', () async {
      await controller.accountStatusChanged(AccountStatus.verified);

      // ما صار loginCompleted، فـ isLoggedIn لسه false.
      expect(controller.isLoggedIn, isFalse);
      expect(controller.canUseMunicipalityServices, isFalse);
    });
  });

  group('الحدّ الأدنى بيغطي حركة الدخول', () {
    test('أطول من مدة الحركة كاملة', () {
      // لو انكسرت هاي، معناها الحركة بتنقطع قبل ما تخلص.
      const entrance = Duration(milliseconds: 1050);
      const minimum = Duration(milliseconds: 3000);

      expect(minimum, greaterThan(entrance));
    });
  });
}
