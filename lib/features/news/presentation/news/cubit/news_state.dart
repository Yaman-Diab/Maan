// -------------------------
// News State
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../domain/entities/news_item.dart';

enum NewsStatus { loading, empty, error, ready }

final class NewsState extends Equatable {
  final NewsStatus status;
  final List<NewsItem> items;
  final String? errorMessage;

  const NewsState({
    this.status = NewsStatus.loading,
    this.items = const [],
    this.errorMessage,
  });

  NewsState copyWith({
    NewsStatus? status,
    List<NewsItem>? items,
    String? errorMessage,
  }) {
    return NewsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
