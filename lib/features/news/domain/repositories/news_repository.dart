// -------------------------
// News Repository
// -------------------------

import '../../../../core/result/result.dart';
import '../entities/news_item.dart';

abstract class NewsRepository {
  /// الأخبار والإعلانات المعتمدة، الأحدث أولاً.
  ///
  /// ✅ `GET /api/news` — الترتيب مفروض بطبقة data (`NewsRepositoryImpl`)
  /// لأن العقد ما بيضمنه.
  Future<Result<List<NewsItem>>> getNews();
}
