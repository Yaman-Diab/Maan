// -------------------------
// News Remote Data Source
// -------------------------

import '../../domain/entities/news_item.dart';

/// المكان الوحيد اللي بيعرف endpoints الأخبار.
abstract class NewsRemoteDataSource {
  /// ✅ `GET /api/news` — حقيقي. الباك اند بيرجّع المعتمدة
  /// (`status = approved`) بس.
  Future<List<NewsItem>> getNews();
}
