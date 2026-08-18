// -------------------------
// News Cubit
// -------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/result/result.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/get_news_usecase.dart';
import 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final GetNewsUseCase _getNews;

  NewsCubit(this._getNews) : super(const NewsState());

  Future<void> load() async {
    emit(state.copyWith(status: NewsStatus.loading));

    final result = await _getNews(const NoParams());

    if (isClosed) return;

    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            status: value.isEmpty ? NewsStatus.empty : NewsStatus.ready,
            items: value,
          ),
        );

      case Err(:final failure):
        emit(
          state.copyWith(
            status: NewsStatus.error,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
