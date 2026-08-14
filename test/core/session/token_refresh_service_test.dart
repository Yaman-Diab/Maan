import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/session/token_refresh_service.dart';
import 'package:maan/core/storage/secure_storage_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements SecureStorageService {}

/// محوّل Dio مزيّف — نفس نمط `auth_repository_impl_test.dart`.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respond);

  final ResponseBody Function() respond;
  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    return respond();
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Map<String, dynamic> body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

TokenRefreshService _service(_FakeAdapter adapter, SecureStorageService storage) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter;

  return TokenRefreshService(dio: dio, storage: storage);
}

void main() {
  setUpAll(() {
    registerFallbackValue(Options());
  });

  group('نجاح — نسخة طبق الأصل عن رد حقيقي', () {
    test('بيحفظ التوكن الجديد', () async {
      final storage = _MockSecureStorage();
      when(() => storage.getAccessToken()).thenAnswer((_) async => 'old-token');
      when(() => storage.saveAccessToken(any())).thenAnswer((_) async {});

      final adapter = _FakeAdapter(
        () => _json({
          'status': 1,
          'message': 'User Token refreshed successfully',
          'data': {'token': 'new-token', 'token_type': 'Bearer'},
        }, 200),
      );

      await _service(adapter, storage).refreshTokenIfNeeded();

      verify(() => storage.saveAccessToken('new-token')).called(1);
    });
  });

  group('فشل — أشكال حقيقية موثّقة من الباك اند', () {
    test(
      '«Token not provided» — status:1 رغم إنه فشل، data:null',
      () async {
        // ⚠️ هاي بالضبط الحالة يلي `ApiEnvelope` القياسية ما بتلتقطها
        // (status ما يساوي صفر) — الحماية هون من غياب `data.token`
        // صراحة، مش من `status`.
        final storage = _MockSecureStorage();
        when(() => storage.getAccessToken()).thenAnswer((_) async => 'old-token');

        final adapter = _FakeAdapter(
          () => _json({
            'status': 1,
            'message': 'Token not provided',
            'data': null,
          }, 200),
        );

        await expectLater(
          _service(adapter, storage).refreshTokenIfNeeded(),
          throwsA(isA<TokenRefreshException>()),
        );

        verifyNever(() => storage.saveAccessToken(any()));
      },
    );

    test('«Wrong number of segments» — status:0', () async {
      final storage = _MockSecureStorage();
      when(() => storage.getAccessToken()).thenAnswer((_) async => 'old-token');

      final adapter = _FakeAdapter(
        () => _json({
          'status': 0,
          'message': 'Wrong number of segments',
          'errors': {
            'general': ['Wrong number of segments'],
          },
        }, 200),
      );

      await expectLater(
        _service(adapter, storage).refreshTokenIfNeeded(),
        throwsA(isA<TokenRefreshException>()),
      );

      verifyNever(() => storage.saveAccessToken(any()));
    });

    test('«Could not decode token» — status:0', () async {
      final storage = _MockSecureStorage();
      when(() => storage.getAccessToken()).thenAnswer((_) async => 'old-token');

      final adapter = _FakeAdapter(
        () => _json({
          'status': 0,
          'message': 'Could not decode token: Error while decoding from JSON',
          'errors': {
            'general': ['Could not decode token: Error while decoding from JSON'],
          },
        }, 200),
      );

      await expectLater(
        _service(adapter, storage).refreshTokenIfNeeded(),
        throwsA(isA<TokenRefreshException>()),
      );

      verifyNever(() => storage.saveAccessToken(any()));
    });
  });

  group('بلا توكن حالي', () {
    test('بيرفض بلا ما يبعت طلب شبكة أصلاً', () async {
      final storage = _MockSecureStorage();
      when(() => storage.getAccessToken()).thenAnswer((_) async => null);

      final adapter = _FakeAdapter(() => _json({'status': 1}, 200));

      await expectLater(
        _service(adapter, storage).refreshTokenIfNeeded(),
        throwsA(isA<TokenRefreshException>()),
      );

      expect(adapter.callCount, 0);
    });
  });

  group('تزامن الطلبات', () {
    test('نداءان متزامنان بيولّدوا طلب شبكة واحد بس', () async {
      final storage = _MockSecureStorage();
      when(() => storage.getAccessToken()).thenAnswer((_) async => 'old-token');
      when(() => storage.saveAccessToken(any())).thenAnswer((_) async {});

      final adapter = _FakeAdapter(
        () => _json({
          'status': 1,
          'data': {'token': 'new-token'},
        }, 200),
      );

      final service = _service(adapter, storage);

      await Future.wait([
        service.refreshTokenIfNeeded(),
        service.refreshTokenIfNeeded(),
      ]);

      expect(adapter.callCount, 1);
    });
  });
}
