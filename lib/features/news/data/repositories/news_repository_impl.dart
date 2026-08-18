// -------------------------
// News Repository Impl
// -------------------------

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource _remoteDataSource;

  const NewsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<NewsItem>>> getNews() async {
    try {
      final news = await _remoteDataSource.getNews();

      // الأحدث أولاً — الترتيب مسؤوليتنا لأن المصدر ما بيضمنه.
      final sorted = [...news]
        ..sort((a, b) {
          final left = a.publishedAt;
          final right = b.publishedAt;

          if (left == null && right == null) return 0;
          if (left == null) return 1;
          if (right == null) return -1;

          return right.compareTo(left);
        });

      return Ok(sorted);
    } catch (error) {
      return Err(FailureMapper.fromError(error));
    }
  }
}
