import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/media/picked_image.dart';
import 'package:maan/core/network/api_client.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/features/verification/data/datasources/verification_remote_data_source.dart';
import 'package:maan/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:maan/features/verification/domain/entities/verification_request_status.dart';

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

/// نسخة طبق الأصل عن استجابة `POST /api/verification/store` الحقيقية.
Map<String, dynamic> _successBody() {
  return {
    'status': 1,
    'message': 'your request has been submitted',
    'data': {
      'user_id': 1,
      'national_id': '12345678901',
      'status': 'pending',
      'updated_at': '2026-08-02T08:38:45.000000Z',
      'created_at': '2026-08-02T08:38:45.000000Z',
      'id': 1,
      'images': [
        {
          'id': 1,
          'verification_request_id': 1,
          'image_url':
              'http://localhost/storage/uploads/personalPhotos/1785659925_2bdfe06d-489e-421c-96ae-6da426f8c958.png',
          'created_at': '2026-08-02T08:38:45.000000Z',
          'updated_at': '2026-08-02T08:38:45.000000Z',
          'deleted_at': null,
        },
        {
          'id': 2,
          'verification_request_id': 1,
          'image_url':
              'http://localhost/storage/uploads/personalPhotos/1785659925_716b1378-720c-4b8e-b3be-a41bde900403.jpg',
          'created_at': '2026-08-02T08:38:45.000000Z',
          'updated_at': '2026-08-02T08:38:45.000000Z',
          'deleted_at': null,
        },
      ],
    },
  };
}

/// نسخة طبق الأصل عن استجابة الفشل الحقيقية — بلا صور.
Map<String, dynamic> _missingImagesBody() {
  return {
    'success': false,
    'message': 'Validation Error.',
    'errors': {
      'images': ['The images field is required.'],
    },
  };
}

/// نسخة طبق الأصل عن استجابة الفشل الحقيقية — عدد صور خطأ.
///
/// "must contain 2 items" يعني قاعدة `size:2` بالباك اند — العدد ثابت
/// لا حد أدنى، فصورة وحدة أو ثلاث بترجّع نفس الخطأ.
Map<String, dynamic> _wrongImageCountBody() {
  return {
    'success': false,
    'message': 'Validation Error.',
    'errors': {
      'images': ['The images field must contain 2 items.'],
    },
  };
}

List<PickedImage> _twoImages() {
  return [
    PickedImage(
      path: '/tmp/a.jpg',
      bytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'a.jpg',
    ),
    PickedImage(
      path: '/tmp/b.jpg',
      bytes: Uint8List.fromList([4, 5, 6]),
      fileName: 'b.jpg',
    ),
  ];
}

({VerificationRepositoryImpl repository, _FakeAdapter adapter}) _buildWith(
  ResponseBody Function() respond,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  final adapter = _FakeAdapter(respond);
  dio.httpClientAdapter = adapter;

  return (
    repository: VerificationRepositoryImpl(
      VerificationRemoteDataSourceImpl(ApiClient(dio)),
    ),
    adapter: adapter,
  );
}

void main() {
  group('تقديم طلب التوثيق — الاستجابة الحقيقية', () {
    test('POST على /api/verification/store بحقل national_id وصورتين', () async {
      final built = _buildWith(() => _json(_successBody(), 200));

      await built.repository.submit(
        nationalId: '12345678901',
        images: _twoImages(),
      );

      final captured = built.adapter.captured!;
      expect(captured.method, 'POST');
      expect(captured.path, '/api/verification/store');

      final data = captured.data;
      expect(data, isA<FormData>());
      final formData = data as FormData;

      expect(
        formData.fields.singleWhere((f) => f.key == 'national_id').value,
        '12345678901',
      );

      // اسم الحقل لازم يكون `images[]` صريحاً — PHP ما بيجمّع الملفات
      // بمصفوفة إلا لو الاسم منتهي بـ`[]` على مستوى السلك.
      final imageFiles = formData.files.where((f) => f.key == 'images[]');
      expect(imageFiles, hasLength(2));
      expect(imageFiles.map((f) => f.value.filename), ['a.jpg', 'b.jpg']);
    });

    test('بتقرأ الحقول الأساسية والصور', () async {
      final built = _buildWith(() => _json(_successBody(), 200));

      final result = await built.repository.submit(
        nationalId: '12345678901',
        images: _twoImages(),
      );

      final request = (result as Ok).value;
      expect(request.id, 1);
      expect(request.userId, 1);
      expect(request.nationalId, '12345678901');
      expect(request.status, VerificationRequestStatus.pending);
      expect(request.images, hasLength(2));
      expect(
        request.images.first.imageUrl,
        contains('2bdfe06d-489e-421c-96ae-6da426f8c958.png'),
      );
    });

    test('حالة غير معروفة برجعها الباك اند بترجع unknown بدل ما ترمي', () async {
      final body = _successBody();
      (body['data'] as Map)['status'] = 'approved';

      final built = _buildWith(() => _json(body, 200));

      final result = await built.repository.submit(
        nationalId: '12345678901',
        images: _twoImages(),
      );

      expect(
        (result as Ok).value.status,
        VerificationRequestStatus.unknown,
      );
    });
  });

  group('فشل التحقق — بلا صور', () {
    test('خطأ الصور المطلوبة بيتحوّل لـ Failure بحقل errors', () async {
      final built = _buildWith(() => _json(_missingImagesBody(), 422));

      final result = await built.repository.submit(
        nationalId: '12345678901',
        images: const [],
      );

      expect(result, isA<Err>());
    });

    test('نفس الخطأ برمز 200 (مظروف فاشل) بينكشف كمان', () async {
      // بعض مسارات الباك اند بترجّع الفشل بـHTTP 200 — `ApiEnvelope`
      // بتكشفه عبر `success: false` بغضّ النظر عن رمز الحالة.
      final built = _buildWith(() => _json(_missingImagesBody(), 200));

      final result = await built.repository.submit(
        nationalId: '12345678901',
        images: const [],
      );

      expect(result, isA<Err>());
    });

    test('عدد صور خطأ (صورة وحدة) بيرجّع نفس نوع الخطأ — العدد ثابت لا حد أدنى', () async {
      final built = _buildWith(() => _json(_wrongImageCountBody(), 422));

      final result = await built.repository.submit(
        nationalId: '12345678901',
        images: [_twoImages().first],
      );

      final failure = (result as Err).failure;
      expect(failure, isA<ValidationFailure>());
      expect(
        (failure as ValidationFailure).fieldErrors?['images'],
        contains('The images field must contain 2 items.'),
      );
    });
  });
}
