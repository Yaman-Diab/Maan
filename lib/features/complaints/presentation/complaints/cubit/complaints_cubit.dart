// -------------------------
// Complaints Cubit
// -------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/result/result.dart';
import '../../../../../core/session/app_session_controller.dart';
import '../../../domain/entities/complaint.dart';
import '../../../domain/entities/complaint_category.dart';
import '../../../domain/entities/complaint_sort.dart';
import '../../../domain/entities/complaint_type.dart';
import '../../../domain/usecases/get_my_complaints_usecase.dart';
import '../../../domain/usecases/get_published_complaints_usecase.dart';
import '../../../domain/usecases/unvote_complaint_usecase.dart';
import '../../../domain/usecases/vote_complaint_usecase.dart';
import 'complaints_state.dart';

class ComplaintsCubit extends Cubit<ComplaintsState> {
  final GetPublishedComplaintsUseCase _getPublished;
  final GetMyComplaintsUseCase _getMine;
  final VoteComplaintUseCase _vote;
  final UnvoteComplaintUseCase _unvote;
  final AppSessionController _session;

  static const int _pageSize = 10;

  ComplaintsCubit(
    this._getPublished,
    this._getMine,
    this._vote,
    this._unvote,
    this._session,
  ) : super(const ComplaintsState());

  Future<void> load() async {
    emit(
      state.copyWith(
        status: ComplaintsListStatus.loading,
        page: 1,
        canParticipate: _session.canUseMunicipalityServices,
      ),
    );

    await _fetch(page: 1);
  }

  Future<void> retry() => load();

  Future<void> changeTab(ComplaintsTab tab) async {
    if (tab == state.tab) return;

    emit(
      state.copyWith(tab: tab, status: ComplaintsListStatus.loading, page: 1),
    );
    await _fetch(page: 1);
  }

  Future<void> setTypeFilter(ComplaintType? type) async {
    emit(
      state.copyWith(
        typeFilter: type,
        clearTypeFilter: type == null,
        status: ComplaintsListStatus.loading,
        page: 1,
      ),
    );
    await _fetch(page: 1);
  }

  Future<void> setCategoryFilter(ComplaintCategory? category) async {
    emit(
      state.copyWith(
        categoryFilter: category,
        clearCategoryFilter: category == null,
        status: ComplaintsListStatus.loading,
        page: 1,
      ),
    );
    await _fetch(page: 1);
  }

  Future<void> setSort(ComplaintSort sort) async {
    emit(
      state.copyWith(sort: sort, status: ComplaintsListStatus.loading, page: 1),
    );
    await _fetch(page: 1);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));
    await _fetch(page: state.page + 1, append: true);
  }

  Future<void> _fetch({required int page, bool append = false}) async {
    final result = state.tab == ComplaintsTab.published
        ? await _getPublished(
            GetPublishedComplaintsParams(
              type: state.typeFilter,
              category: state.categoryFilter,
              sort: state.sort,
              page: page,
              pageSize: _pageSize,
            ),
          )
        : await _getMine(
            GetMyComplaintsParams(page: page, pageSize: _pageSize),
          );

    if (isClosed) return;

    switch (result) {
      case Ok(:final value):
        final items = append ? [...state.items, ...value] : value;

        emit(
          state.copyWith(
            status: items.isEmpty
                ? ComplaintsListStatus.empty
                : ComplaintsListStatus.ready,
            items: items,
            page: page,
            hasMore: value.length == _pageSize,
            isLoadingMore: false,
          ),
        );

      case Err(:final failure):
        emit(
          state.copyWith(
            status: append ? state.status : ComplaintsListStatus.error,
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
    }
  }

  /// تفاؤلي: العدّاد والحالة بيتغيّروا فوراً، وبيترجعوا لو فشل الطلب —
  /// نفس منطق إزالة الصورة بالبروفايل.
  Future<void> toggleVote(Complaint complaint) async {
    if (!state.canParticipate) return;

    final wasVoted = complaint.hasVoted;
    final optimistic = complaint.copyWith(
      hasVoted: !wasVoted,
      votes: complaint.votes + (wasVoted ? -1 : 1),
    );

    emit(state.copyWith(items: _replace(optimistic)));

    final result = wasVoted
        ? await _unvote(complaint.id)
        : await _vote(complaint.id);

    if (isClosed) return;

    if (result case Err()) {
      emit(state.copyWith(items: _replace(complaint)));
    }
  }

  List<Complaint> _replace(Complaint updated) {
    return [
      for (final item in state.items)
        if (item.id == updated.id) updated else item,
    ];
  }
}
