import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/network/api_client.dart';
import 'package:maan/core/network/api_endpoints.dart';
import 'package:maan/core/network/api_request_flags.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:maan/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:maan/features/auth/domain/entities/auth_session.dart';

/// محوّل Dio مزيّف: بيمسك الطلب الصادر وبيرجّع رد جاهز.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respond);

  final ResponseBody Function() respond;
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
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

({AuthRepositoryImpl repository, _FakeAdapter adapter}) _build(
  ResponseBody Function() respond,
) {
  final adapter = _FakeAdapter(respond);
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter;

  return (
    repository: AuthRepositoryImpl(AuthRemoteDataSourceImpl(ApiClient(dio))),
    adapter: adapter,
  );
}

void main() {
  group('شكل الطلب — ضمان عدم الارتداد عن السلوك القديم', () {
    test('بينادي endpoint تسجيل الدخول بـ POST وبنفس جسم الطلب', () async {
      final sut = _build(
        () => _json({'access': 'a', 'refresh': 'r'}, 200),
      );

      await sut.repository.login(email: 'a@b.com', password: 'secret');

      final request = sut.adapter.captured!;

      expect(request.path, ApiEndpoints.login);
      expect(request.method, 'POST');
      expect(request.data, {'email': 'a@b.com', 'password': 'secret'});
    });

    test('بيمرّر أعلام تخطي المصادقة لأن الـ endpoint عام', () async {
      final sut = _build(
        () => _json({'access': 'a', 'refresh': 'r'}, 200),
      );

      await sut.repository.login(email: 'a@b.com', password: 'secret');

      final extra = sut.adapter.captured!.extra;

      expect(extra[ApiRequestFlags.skipAuthHeader], isTrue);
      expect(extra[ApiRequestFlags.skipAuthRefresh], isTrue);
    });
  });

  group('قراءة الاستجابة', () {
    test('بتقرأ التوكنات من جذر الاستجابة', () async {
      final sut = _build(
        () => _json({
          'access': 'access-token',
          'refresh': 'refresh-token',
        }, 200),
      );

      final result = await sut.repository.login(
        email: 'a@b.com',
        password: 'secret',
      );

      expect(result, isA<Ok<AuthSession>>());
      expect(result.valueOrNull?.accessToken, 'access-token');
      expect(result.valueOrNull?.refreshToken, 'refresh-token');
    });

    test('بتقرأ التوكنات لو كانت مغلّفة تحت data', () async {
      final sut = _build(
        () => _json({
          'data': {'access': 'access-token', 'refresh': 'refresh-token'},
        }, 200),
      );

      final result = await sut.repository.login(
        email: 'a@b.com',
        password: 'secret',
      );

      expect(result.valueOrNull?.accessToken, 'access-token');
    });

    test('نقص توكن بيرجع فشل بدل ما يرمي استثناء', () async {
      final sut = _build(() => _json({'access': 'only-access'}, 200));

      final result = await sut.repository.login(
        email: 'a@b.com',
        password: 'secret',
      );

      expect(result, isA<Err<AuthSession>>());
      expect(result.failureOrNull, isA<UnknownFailure>());
      expect(result.failureOrNull?.message, 'تعذر قراءة استجابة الخادم');
    });
  });

  group('مسار الفشل — الاستثناءات بتتحوّل لـ Failure', () {
    test('401 ببيانات دخول خاطئة بترجع AuthFailure برسالة عربية', () async {
      final sut = _build(
        () => _json({'code': 'invalid_credentials'}, 401),
      );

      final result = await sut.repository.login(
        email: 'a@b.com',
        password: 'wrong',
      );

      expect(result, isA<Err<AuthSession>>());
      expect(result.failureOrNull, isA<AuthFailure>());
      expect(
        result.failureOrNull?.message,
        'رقم الهاتف أو كلمة المرور غير صحيحة',
      );
    });

    test('500 بترجع ServerFailure', () async {
      final sut = _build(() => _json({'message': 'boom'}, 500));

      final result = await sut.repository.login(
        email: 'a@b.com',
        password: 'secret',
      );

      expect(result.failureOrNull, isA<ServerFailure>());
    });

    test('انقطاع الاتصال بيرجع NetworkFailure', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = _ThrowingAdapter();

      final repository = AuthRepositoryImpl(
        AuthRemoteDataSourceImpl(ApiClient(dio)),
      );

      final result = await repository.login(
        email: 'a@b.com',
        password: 'secret',
      );

      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(
        result.failureOrNull?.message,
        'تعذر الاتصال بالخادم، تحقق من الإنترنت وحاول مرة أخرى',
      );
    });
  });
}

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'no internet',
    );
  }

  @override
  void close({bool force = false}) {}
}
