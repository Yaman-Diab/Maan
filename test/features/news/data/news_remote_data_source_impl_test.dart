import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/network/api_client.dart';
import 'package:maan/features/news/data/datasources/news_remote_data_source_impl.dart';

/// محوّل Dio مزيّف: بيمسك الطلب الصادر وبيرجّع رد جاهز — نفس نمط
/// `profile_repository_impl_test.dart`.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respond);

  final ResponseBody Function() respond;
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return respond();
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// ⚠️ **مثال استجابة حقيقي** — كشف باگ حقيقي: الطلب كان يرسل
/// `type=news` كفلتر، بينما هالمثال بيرجع النوعين (`news`/`announcement`)
/// مع بعض. راجع `ApiEndpoints.news` للتفاصيل الكاملة.
Map<String, dynamic> _realNewsResponse() {
  return {
    'status': 1,
    'message': 'Published news retrieved successfully',
    'data': {
      'current_page': 1,
      'page_size': 10,
      'total': 2,
      'last_page': 1,
      'has_more_pages': false,
      'data': [
        {
          'id': 2,
          'title': 'تلتلت',
          'description': 'اتايلبتلنم',
          'type': 'news',
          'published_at': '2026-08-18T03:41:35.000000Z',
          'location': {'latitude': '65.0000000', 'longitude': '3.0000000'},
          'media': [
            {
              'id': 1,
              'file_path':
                  'news/images/CeVuWdqVUB1LycO9ElFGowcu4I8YB2eOhuXWLnXD.png',
              'media_type': 'image',
              'file_url':
                  'http://x/storage/news/images/CeVuWdqVUB1LycO9ElFGowcu4I8YB2eOhuXWLnXD.png',
            },
          ],
        },
        {
          'id': 1,
          'title': 'اصلاح الجسر',
          'description': 'سنقوم بهد الجسر و اعادة بنائه',
          'type': 'announcement',
          'published_at': '2026-08-18T03:38:50.000000Z',
          'location': {'latitude': '33.2662000', 'longitude': '36.3330000'},
          'media': <dynamic>[],
        },
      ],
    },
  };
}

void main() {
  test('⚠️ الطلب بلا type — باگ حقيقي كان بيخفي الإعلانات لو الباك اند '
      'بيفلتر فعلياً حسب النوع', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    final adapter = _FakeAdapter(() => _json(_realNewsResponse()));
    dio.httpClientAdapter = adapter;

    final dataSource = NewsRemoteDataSourceImpl(ApiClient(dio));
    await dataSource.getNews();

    final query = adapter.captured!.queryParameters;
    expect(query.containsKey('type'), isFalse);
    expect(query['page'], 1);
  });

  test('يقرأ العنصرين — الشكل المتداخل data.data (ترقيم Laravel)', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    final adapter = _FakeAdapter(() => _json(_realNewsResponse()));
    dio.httpClientAdapter = adapter;

    final dataSource = NewsRemoteDataSourceImpl(ApiClient(dio));
    final result = await dataSource.getNews();

    expect(result, hasLength(2));
    expect(result.map((n) => n.id), containsAll([1, 2]));

    final withImage = result.firstWhere((n) => n.id == 2);
    expect(withImage.hasImage, isTrue);

    final withoutImage = result.firstWhere((n) => n.id == 1);
    expect(withoutImage.hasImage, isFalse);
  });
}
