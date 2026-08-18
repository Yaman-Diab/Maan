// -------------------------
// News Remote Data Source Impl
// -------------------------

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/news_item.dart';
import '../models/news_item_model.dart';
import 'news_remote_data_source.dart';

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final ApiClient _apiClient;

  const NewsRemoteDataSourceImpl(this._apiClient);

  /// حجم صفحة واحد كبير بدل ترقيم حقيقي — الشاشة بتعرض قائمة وحدة بلا
  /// «تحميل المزيد» (بعكس الشكاوى). لو احتاجت ترقيماً لاحقاً، الـ
  /// endpoint بيدعمه أصلاً (`page`/`page_size`).
  static const int _pageSize = 15;

  /// ⚠️ الباك اند بيفلتر `status = approved` لحاله — بلا فلترة إضافية
  /// هون.
  @override
  Future<List<NewsItem>> getNews() async {
    final response = await _apiClient.request(
      endpoint: ApiEndpoints.news,
      method: ApiMethod.get,
      queryParameters: {'type': 'news', 'page': 1, 'page_size': _pageSize},
    );

    return NewsItemModel.listFromResponse(response);
  }
}
