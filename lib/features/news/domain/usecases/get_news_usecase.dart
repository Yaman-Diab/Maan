// -------------------------
// Get News Use Case
// -------------------------

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/news_item.dart';
import '../repositories/news_repository.dart';

class GetNewsUseCase implements UseCase<List<NewsItem>, NoParams> {
  final NewsRepository _repository;

  const GetNewsUseCase(this._repository);

  @override
  Future<Result<List<NewsItem>>> call(NoParams params) {
    return _repository.getNews();
  }
}
