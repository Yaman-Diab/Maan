import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/network/api_client.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/core/network/api_request_flags.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:maan/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:maan/features/auth/domain/entities/auth_session.dart';
import 'package:maan/core/domain/birth_date.dart';

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

ResponseBody _json(Map<String, dynamic> body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// نسخة طبق الأصل عن استجابة `/api/auth/login` الحقيقية (مأخوذة من
/// لوغ فعلي)، فيما عدا قيمة التوكن — مقصوصة لتبقى مقروءة.
Map<String, dynamic> _loginResponseBody() {
  return {
    'status': 1,
    'message': 'User logged in successfully',
    'data': {
      'id': 1,
      'first_name': 'Yaman',
      'last_name': 'Diab',
      'email': 'yamandiab7@gmail.com',
      'phone': null,
      'national_id': null,
      'birth_date': '2003-01-01',
      'email_verified_at': null,
      'privacy_policy_accepted': 0,
      'terms_of_service_accepted': 0,
      'fcm_token': null,
      'account_status': 'visitor',
      'verification_attempts': 0,
      'expires_at': null,
      'created_at': '2026-08-01T04:53:26.000000Z',
      'updated_at': '2026-08-01T04:53:26.000000Z',
      'deleted_at': null,
      'token': 'the-token',
      'token_type': 'Bearer',
    },
  };
}

({AuthRepositoryImpl repository, _FakeAdapter adapter}) _build([
  ResponseBody Function()? respond,
]) {
  final adapter = _FakeAdapter(respond ?? () => _json({}, 200));
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter;

  return (
    repository: AuthRepositoryImpl(AuthRemoteDataSourceImpl(ApiClient(dio))),
    adapter: adapter,
  );
}

void main() {
  group('login — مطابقة عقد collection.md', () {
    test('POST /api/auth/login بجسم البريد وكلمة المرور', () async {
      final sut = _build(() => _json(_loginResponseBody(), 200));

      await sut.repository.login(email: 'a@b.com', password: 'secret');

      final request = sut.adapter.captured!;

      expect(request.path, '/api/auth/login');
      expect(request.method, 'POST');
      expect(request.data, {'email': 'a@b.com', 'password': 'secret'});
    });

    test('بيمرّر أعلام تخطي المصادقة لأن الـ endpoint عام', () async {
      final sut = _build(() => _json(_loginResponseBody(), 200));

      await sut.repository.login(email: 'a@b.com', password: 'secret');

      final extra = sut.adapter.captured!.extra;

      expect(extra[ApiRequestFlags.skipAuthHeader], isTrue);
      expect(extra[ApiRequestFlags.skipAuthRefresh], isTrue);
    });
  });

  group('register — مطابقة عقد collection.md', () {
    test('POST /api/auth/register بمفاتيح snake_case كاملة', () async {
      final sut = _build();

      await sut.repository.register(
        firstName: 'mohammed',
        lastName: 'sheikh-alard',
        birthDate: const BirthDate(day: 1, month: 2, year: 2003),
        nationalId: '09477224563',
        email: 'mohmadhd2003@gmail.com',
        password: 'password1A@',
        passwordConfirmation: 'password1A@',
      );

      final request = sut.adapter.captured!;

      expect(request.path, '/api/auth/register');
      expect(request.data, {
        'first_name': 'mohammed',
        'last_name': 'sheikh-alard',
        'birth_date': '2003/2/1',
        'national_id': '09477224563',
        'email': 'mohmadhd2003@gmail.com',
        'password': 'password1A@',
        'password_confirmation': 'password1A@',
      });
    });
  });

  group('checkCode — مطابقة عقد collection.md', () {
    test('POST /api/auth/checkCode بالرمز فقط بلا بريد', () async {
      final sut = _build();

      await sut.repository.checkCode(code: '900482');

      final request = sut.adapter.captured!;

      expect(request.path, '/api/auth/checkCode');
      expect(request.data, {'code': '900482'});
    });
  });

  group('resendVerification', () {
    test('POST /api/email/verification-notification بتوكن المستخدم', () async {
      final sut = _build();

      await sut.repository.resendVerification();

      final request = sut.adapter.captured!;

      expect(request.path, '/api/email/verification-notification');
      // مش endpoint عام، فما بينحط عليه علم تخطي المصادقة.
      expect(request.extra[ApiRequestFlags.skipAuthHeader], isNull);
    });
  });

  group('forgetPassword / resetPassword — مطابقة عقد collection.md', () {
    test('POST /api/auth/forgetPassword بالبريد فقط', () async {
      final sut = _build();

      await sut.repository.forgetPassword(email: 'ehsansawan7@gmail.com');

      final request = sut.adapter.captured!;

      expect(request.path, '/api/auth/forgetPassword');
      expect(request.data, {'email': 'ehsansawan7@gmail.com'});
    });

    test('POST /api/auth/resetPassword بالرمز والكلمتين بلا بريد', () async {
      final sut = _build();

      await sut.repository.resetPassword(
        code: '900482',
        password: 'password1!A',
        passwordConfirmation: 'password1!A',
      );

      final request = sut.adapter.captured!;

      expect(request.path, '/api/auth/resetPassword');
      expect(request.data, {
        'password': 'password1!A',
        'password_confirmation': 'password1!A',
        'code': '900482',
      });
    });
  });

  group('قراءة استجابة تسجيل الدخول — الشكل الحقيقي', () {
    test('بتقرأ التوكن والمستخدم من data', () async {
      final sut = _build(() => _json(_loginResponseBody(), 200));

      final result = await sut.repository.login(
        email: 'a@b.com',
        password: 'secret',
      );

      expect(result, isA<Ok<AuthSession>>());
      expect(result.valueOrNull?.accessToken, 'the-token');
      expect(result.valueOrNull?.user.id, 1);
      expect(result.valueOrNull?.user.email, 'yamandiab7@gmail.com');
      expect(result.valueOrNull?.user.accountStatus, AccountStatus.visitor);
    });

    test('بتقرأ التوكن لو كان بجذر الاستجابة بلا غلاف data', () async {
      final sut = _build(
        () => _json(_loginResponseBody()['data'] as Map<String, dynamic>, 200),
      );

      final result = await sut.repository.login(
        email: 'a@b.com',
        password: 'secret',
      );

      expect(result.valueOrNull?.accessToken, 'the-token');
    });

    test('نقص التوكن بيرجع فشل بدل ما يرمي استثناء', () async {
      final body = _loginResponseBody();
      (body['data'] as Map<String, dynamic>).remove('token');

      final sut = _build(() => _json(body, 200));

      final result = await sut.repository.login(
        email: 'a@b.com',
        password: 'secret',
      );

      expect(result, isA<Err<AuthSession>>());
      expect(result.failureOrNull, isA<UnknownFailure>());
      expect(result.failureOrNull?.message, 'error_unreadable_response');
    });

    test('نقص حقول المستخدم بيرجع فشل بدل ما يرمي استثناء', () async {
      final sut = _build(
        () => _json({
          'status': 1,
          'data': {'id': 1, 'token': 'the-token'},
        }, 200),
      );

      final result = await sut.repository.login(
        email: 'a@b.com',
        password: 'secret',
      );

      expect(result, isA<Err<AuthSession>>());
      expect(result.failureOrNull, isA<UnknownFailure>());
    });
  });

  group('مسار الفشل — الاستثناءات بتتحوّل لـ Failure', () {
    test('401 ببيانات دخول خاطئة بترجع AuthFailure بمفتاح الرسالة', () async {
      final sut = _build(() => _json({'code': 'invalid_credentials'}, 401));

      final result = await sut.repository.login(
        email: 'a@b.com',
        password: 'wrong',
      );

      expect(result.failureOrNull, isA<AuthFailure>());
      expect(result.failureOrNull?.message, 'error_invalid_credentials');
    });

    test(
      '401 بالشكل الحقيقي (بلا code، رسالة نصّية فقط) بترجع نفس الخطأ',
      () async {
        // نسخة طبق الأصل عن استجابة حقيقية من الباك اند — بلا `code`،
        // وبـ`status: 1` (حقل مضلِّل هون، بس ما بيهم لأن 401 مش 2xx فما
        // بيمرّ على فحص المظروف أصلاً). كان هالشكل بيوقع على الرسالة
        // العامة «سجّل دخولك من جديد» بدل رسالة بيانات الدخول الخاطئة،
        // لأن الفرع القديم كان بيعتمد حصرياً على وجود `code`.
        final sut = _build(
          () => _json({
            'status': 1,
            'message': 'your email or password is wrong',
            'data': null,
          }, 401),
        );

        final result = await sut.repository.login(
          email: 'a@b.com',
          password: 'wrong',
        );

        expect(result.failureOrNull, isA<AuthFailure>());
        expect(result.failureOrNull?.message, 'error_invalid_credentials');
      },
    );

    test('422 بأخطاء حقول بترجع ValidationFailure بتفاصيلها', () async {
      // 422 هو الرمز الحقيقي يلي بيرجّعه الباك اند لأخطاء التحقق —
      // كان هالاختبار مسمّى «422» بس جسمه المزيّف بيحمل رمز 400 فعلياً،
      // فمسار 422 الحقيقي ما كان منفحوص أبداً. راجع
      // `FailureMapper._fromStatusCode`.
      final sut = _build(
        () => _json({
          'errors': {
            'national_id': ['The national id field is required.'],
          },
        }, 422),
      );

      final result = await sut.repository.register(
        firstName: 'a',
        lastName: 'b',
        birthDate: const BirthDate(day: 1, month: 1, year: 2000),
        nationalId: '',
        email: 'a@b.com',
        password: 'x',
        passwordConfirmation: 'x',
      );

      final failure = result.failureOrNull;

      expect(failure, isA<ValidationFailure>());
      expect((failure! as ValidationFailure).fieldErrors, {
        'national_id': ['The national id field is required.'],
      });
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
      expect(result.failureOrNull?.message, 'error_connection');
    });
  });
}
