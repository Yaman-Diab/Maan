// -------------------------
// Complaints State
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../domain/entities/complaint.dart';
import '../../../domain/entities/complaint_category.dart';
import '../../../domain/entities/complaint_sort.dart';
import '../../../domain/entities/complaint_type.dart';

enum ComplaintsTab { published, mine }

enum ComplaintsListStatus { loading, empty, error, ready }

final class ComplaintsState extends Equatable {
  final ComplaintsTab tab;
  final ComplaintsListStatus status;
  final List<Complaint> items;

  final ComplaintType? typeFilter;
  final ComplaintCategory? categoryFilter;
  final ComplaintSort sort;

  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  final String? errorMessage;

  /// الحساب الحالي موثّق فيقدر يصوّت ويقدّم شكاوى — من
  /// `AppSessionController.canUseMunicipalityServices` وقت التحميل.
  final bool canParticipate;

  const ComplaintsState({
    this.tab = ComplaintsTab.published,
    this.status = ComplaintsListStatus.loading,
    this.items = const [],
    this.typeFilter,
    this.categoryFilter,
    this.sort = ComplaintSort.priority,
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.canParticipate = false,
  });

  ComplaintsState copyWith({
    ComplaintsTab? tab,
    ComplaintsListStatus? status,
    List<Complaint>? items,
    ComplaintType? typeFilter,
    bool clearTypeFilter = false,
    ComplaintCategory? categoryFilter,
    bool clearCategoryFilter = false,
    ComplaintSort? sort,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
    bool? canParticipate,
  }) {
    return ComplaintsState(
      tab: tab ?? this.tab,
      status: status ?? this.status,
      items: items ?? this.items,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      categoryFilter: clearCategoryFilter
          ? null
          : (categoryFilter ?? this.categoryFilter),
      sort: sort ?? this.sort,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      canParticipate: canParticipate ?? this.canParticipate,
    );
  }

  @override
  List<Object?> get props => [
    tab,
    status,
    items,
    typeFilter,
    categoryFilter,
    sort,
    page,
    hasMore,
    isLoadingMore,
    errorMessage,
    canParticipate,
  ];
}
