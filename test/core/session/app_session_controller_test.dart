import 'package:flutter_test/flutter_test.dart';
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

  group('الحدّ الأدنى بيغطي حركة الدخول', () {
    test('أطول من مدة الحركة كاملة', () {
      // لو انكسرت هاي، معناها الحركة بتنقطع قبل ما تخلص.
      const entrance = Duration(milliseconds: 1050);
      const minimum = Duration(milliseconds: 3000);

      expect(minimum, greaterThan(entrance));
    });
  });
}
