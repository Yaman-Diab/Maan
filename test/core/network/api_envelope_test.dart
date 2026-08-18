import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/error/failure_mapper.dart';
import 'package:maan/core/network/api_client.dart';
import 'package:maan/core/network/api_envelope.dart';
import 'package:maan/core/network/api_exception.dart';

/// حارس ضد أخطر خلل بالتكامل: الـ backend بيرجّع **HTTP 200 عند الفشل**
/// والحالة الحقيقية بالجسم. الأجسام هون منسوخة حرفياً من `collection.md`.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.body, [this.statusCode = 200]);

  final Map<String, dynamic> body;
  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiClient _client(Map<String, dynamic> body, [int status = 200]) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = _Adapter(body, status);

  return ApiClient(dio);
}

Future<dynamic> _get(ApiClient client) {
  return client.request(endpoint: '/x', method: ApiMethod.get);
}

void main() {
  group('ApiEnvelope.indicatesFailure — الإشارات الصريحة', () {
    test('status صفر يعني فشل', () {
      expect(ApiEnvelope.indicatesFailure({'status': 0}), isTrue);
      expect(ApiEnvelope.indicatesFailure({'status': '0'}), isTrue);
    });

    test('success = false يعني فشل', () {
      expect(ApiEnvelope.indicatesFailure({'success': false}), isTrue);
    });

    test('status واحد و success true نجاح', () {
      expect(ApiEnvelope.indicatesFailure({'status': 1}), isFalse);
      expect(ApiEnvelope.indicatesFailure({'success': true}), isFalse);
    });
  });

  group('ApiEnvelope — ما بيكسر الحقول اللي اسمها status بمعنى تاني', () {
    test('حالة نصية مثل خدمة active مش فشل', () {
      // /api/admin/services بيرجّع `"status": "active"` — لو اعتبرناها
      // فشلاً كان كل قراءة خدمة بتنكسر.
      expect(ApiEnvelope.indicatesFailure({'status': 'active'}), isFalse);
      expect(ApiEnvelope.indicatesFailure({'status': 'pending'}), isFalse);
    });

    test('غياب المفتاح أو null مش فشل', () {
      expect(ApiEnvelope.indicatesFailure({'data': 1}), isFalse);
      expect(ApiEnvelope.indicatesFailure({'status': null}), isFalse);
      expect(ApiEnvelope.indicatesFailure(<String, dynamic>{}), isFalse);
    });

    test('استجابة مش Map بتمرّ', () {
      expect(ApiEnvelope.indicatesFailure('نص'), isFalse);
      expect(ApiEnvelope.indicatesFailure([1, 2]), isFalse);
      expect(ApiEnvelope.indicatesFailure(null), isFalse);
    });

    test('success = false النصية مش بوليان فما بتُعتبر فشلاً', () {
      // متحفّظ عمداً: بس البوليان الصريح.
      expect(ApiEnvelope.indicatesFailure({'success': 'false'}), isFalse);
    });
  });

  group('ApiClient — أجسام الفشل الحقيقية من collection.md', () {
    test('شكوى مرفوضة بـ200 بترمي بدل ما تمرّ كنجاح', () async {
      final client = _client({
        'status': 0,
        'message': 'Route not found.',
        'errors': ['route_not_found'],
      });

      await expectLater(_get(client), throwsA(isA<ApiException>()));
    });

    test('رفض الانضمام للطابور بـ200 بيرمي', () async {
      final client = _client({
        'status': 0,
        'message': 'Location not allowed. You must be inside the municipality.',
        'errors': {
          'general': [
            'Location not allowed. You must be inside the municipality.',
          ],
        },
      });

      await expectLater(_get(client), throwsA(isA<ApiException>()));
    });

    test('شكل success:false بيرمي كمان', () async {
      final client = _client({
        'success': false,
        'message': 'Validation Error.',
        'errors': {
          'status.0': ['The selected status.0 is invalid.'],
        },
      });

      await expectLater(_get(client), throwsA(isA<ApiException>()));
    });

    test('استجابة البروفايل الناجحة بتمرّ', () async {
      final client = _client({
        'status': 1,
        'message': 'Profile retrieved successfully',
        'data': {'id': 2, 'citizenship_score': 0},
      });

      final result = await _get(client);

      expect((result as Map)['status'], 1);
    });

    test('استجابة بلا مظروف إطلاقاً بتمرّ — مثل توكنات الدخول', () async {
      final client = _client({'access': 'a', 'refresh': 'r'});

      final result = await _get(client);

      expect((result as Map)['access'], 'a');
    });
  });

  group('تصنيف الفشل المخبّأ', () {
    test('مع أخطاء حقول بيصير ValidationFailure', () async {
      final client = _client({
        'success': false,
        'message': 'Validation Error.',
        'errors': {
          'national_id': ['The national id field is required.'],
        },
      });

      try {
        await _get(client);
        fail('كان لازم يرمي');
      } on ApiException catch (e) {
        final failure = FailureMapper.fromApiException(e);

        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).fieldErrors, {
          'national_id': ['The national id field is required.'],
        });
      }
    });

    test('بلا أخطاء حقول بيصير UnknownFailure مع رسالة الخادم', () async {
      final client = _client({
        'status': 0,
        'message': 'Location not allowed. You must be inside the municipality.',
      });

      try {
        await _get(client);
        fail('كان لازم يرمي');
      } on ApiException catch (e) {
        final failure = FailureMapper.fromApiException(e);

        expect(failure, isA<UnknownFailure>());
        expect(
          failure.message,
          'Location not allowed. You must be inside the municipality.',
        );
      }
    });

    test('errors كمصفوفة نصوص بتعطي كود الخطأ', () async {
      final client = _client({
        'status': 0,
        'message': 'Route not found.',
        'errors': ['route_not_found'],
      });

      try {
        await _get(client);
        fail('كان لازم يرمي');
      } on ApiException catch (e) {
        expect(e.errorCode, 'route_not_found');
      }
    });
  });
}
