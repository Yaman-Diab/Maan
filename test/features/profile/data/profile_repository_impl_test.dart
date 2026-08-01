import 'dart:convert';
// ignore: unnecessary_import — Uint8List مستخدمة صراحةً بحالات الرفع.
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/network/api_client.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:maan/features/profile/data/repositories/profile_repository_impl.dart';

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

Map<String, dynamic> _profileBody() {
  return {
    'status': 1,
    'message': 'ok',
    'data': {
      'id': 7,
      'first_name': 'Yaman',
      'last_name': 'Diab',
      'email': 'yamandiab7@gmail.com',
      'national_id': '123456789012',
      'birth_date': '1998-10-12',
      'account_status': 'verified',
    },
  };
}

({ProfileRepositoryImpl repository, _FakeAdapter adapter}) _buildWith(
  ResponseBody Function() respond,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  final adapter = _FakeAdapter(respond);
  dio.httpClientAdapter = adapter;

  return (
    repository: ProfileRepositoryImpl(
      ProfileRemoteDataSourceImpl(ApiClient(dio)),
    ),
    adapter: adapter,
  );
}

void main() {
  group('شكل الطلب', () {
    test('GET على /api/profile بلا جسم', () async {
      final built = _buildWith(() => _json(_profileBody(), 200));

      await built.repository.getProfile();

      expect(built.adapter.captured!.method, 'GET');
      expect(built.adapter.captured!.path, '/api/profile');
      expect(built.adapter.captured!.data, isNull);
    });

    test('ما بيتجاوز الـ interceptor — المسار محمي فبده توكن', () async {
      final built = _buildWith(() => _json(_profileBody(), 200));

      await built.repository.getProfile();

      // غياب الأعلام معناه إن `AuthInterceptor` بيضيف الـ Bearer عادي.
      expect(built.adapter.captured!.extra, isEmpty);
    });
  });

  group('قراءة الاستجابة', () {
    test('بترجّع Ok مع هوية المواطن', () async {
      final built = _buildWith(() => _json(_profileBody(), 200));

      final result = await built.repository.getProfile();

      expect(result, isA<Ok>());

      final profile = (result as Ok).value;
      expect(profile.user.fullName, 'Yaman Diab');
      expect(profile.user.accountStatus, AccountStatus.verified);
      expect(profile.stats.isEmpty, isTrue);
    });
  });

  group('رفع الصورة الشخصية', () {
    test('POST بـ multipart على /api/profile/avatar بحقل اسمه avatar', () async {
      final built = _buildWith(
        () => _json({'status': 1, 'data': {'avatar_url': 'https://cdn/a.jpg'}}, 200),
      );

      await built.repository.uploadAvatar(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'avatar.jpg',
      );

      final captured = built.adapter.captured!;
      expect(captured.method, 'POST');
      expect(captured.path, '/api/profile/avatar');

      final data = captured.data;
      expect(data, isA<FormData>());

      // اسم الحقل جزء من العقد غير المؤكّد — تثبيته هون بيخلّي أي
      // تغيير عليه قراراً واعياً لا انزلاقاً صامتاً.
      final files = (data as FormData).files;
      expect(files, hasLength(1));
      expect(files.single.key, 'avatar');
      expect(files.single.value.filename, 'avatar.jpg');
    });

    test('بتقرأ الرابط الجديد لو رجّعه السيرفر', () async {
      final built = _buildWith(
        () => _json({'data': {'avatar_url': 'https://cdn/a.jpg'}}, 200),
      );

      final result = await built.repository.uploadAvatar(
        bytes: Uint8List.fromList([1]),
        fileName: 'a.jpg',
      );

      expect((result as Ok).value, 'https://cdn/a.jpg');
    });

    test('غياب الرابط نجاح بقيمة null لا فشل', () async {
      // العقد غير مثبّت — ممكن يرجّع رسالة بس.
      final built = _buildWith(
        () => _json({'status': 1, 'message': 'uploaded'}, 200),
      );

      final result = await built.repository.uploadAvatar(
        bytes: Uint8List.fromList([1]),
        fileName: 'a.jpg',
      );

      expect(result, isA<Ok>());
      expect((result as Ok).value, isNull);
    });

    test('413 بتتحوّل لـ Failure بدل ما ترمي', () async {
      final built = _buildWith(
        () => _json({'message': 'Payload too large'}, 413),
      );

      final result = await built.repository.uploadAvatar(
        bytes: Uint8List.fromList([1]),
        fileName: 'a.jpg',
      );

      expect(result, isA<Err>());
    });
  });

  group('تحويل الأخطاء لـ Failure', () {
    test('انقطاع الاتصال بيصير NetworkFailure', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.httpClientAdapter = _ThrowingAdapter();

      final repository = ProfileRepositoryImpl(
        ProfileRemoteDataSourceImpl(ApiClient(dio)),
      );

      final result = await repository.getProfile();

      expect(result, isA<Err>());
      expect((result as Err).failure, isA<NetworkFailure>());
    });

    test('401 بتصير AuthFailure', () async {
      final built = _buildWith(
        () => _json({'message': 'Unauthenticated.'}, 401),
      );

      final result = await built.repository.getProfile();

      expect((result as Err).failure, isA<AuthFailure>());
    });

    test('فشل مخبّأ بـ HTTP 200 بينكشف كمان', () async {
      // نفس فخّ الباك اند الموثّق: رمز ناجح وحالة فاشلة بالجسم.
      final built = _buildWith(
        () => _json({
          'status': 0,
          'message': 'Token not provided.',
          'errors': ['token_missing'],
        }, 200),
      );

      final result = await built.repository.getProfile();

      expect(result, isA<Err>());
    });
  });
}
