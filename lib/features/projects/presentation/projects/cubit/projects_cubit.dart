// -------------------------
// Projects Cubit
// -------------------------

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/result/result.dart';
import '../../../../../core/session/app_session_controller.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/municipal_project.dart';
import '../../../domain/entities/project_reaction.dart';
import '../../../domain/usecases/get_projects_usecase.dart';
import '../../../domain/usecases/unvote_project_usecase.dart';
import '../../../domain/usecases/vote_project_usecase.dart';
import 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final GetProjectsUseCase _getProjects;
  final VoteProjectUseCase _vote;
  final UnvoteProjectUseCase _unvote;
  final AppSessionController _session;

  ProjectsCubit(this._getProjects, this._vote, this._unvote, this._session)
    : super(const ProjectsState());

  Future<void> load() async {
    emit(
      state.copyWith(
        status: ProjectsStatus.loading,
        canParticipate: _session.canUseMunicipalityServices,
      ),
    );

    await _fetch();
  }

  /// تفعيل «أحبذ»/«لا أحبذ» — `value: true` = أحبذ، `false` = لا أحبذ.
  ///
  /// ⚠️ **`POST` بلا دعم تصويت ثانٍ** (`409` حتى بنفس القيمة) — التبديل
  /// الحصري بينهم بمرحلتين: `DELETE` (سحب الصوت الحالي) ثم `POST`
  /// (الصوت الجديد). الضغط على نفس الخيار المفعّل حالياً بيسحب الصوت
  /// بس (`DELETE` لحاله، بلا `POST` بعده).
  Future<Result<void>> vote(MunicipalProject requested, bool value) async {
    if (!state.canParticipate) return const Ok(null);
    if (state.votingIds.contains(requested.id)) return const Ok(null);

    final current = _findProject(requested.id) ?? requested;
    final targetReaction = value
        ? ProjectReaction.favor
        : ProjectReaction.oppose;

    if (current.myReaction == targetReaction) {
      return _withdraw(current.id);
    }

    if (current.myReaction != ProjectReaction.none) {
      // ⚠️ `refresh: false` — التبديل بيتبعه `_cast` فوراً تحت. لو
      // سمحنا لإعادة التحميل الصامتة تشتغل هون، احتمال حقيقي إنها
      // توصل **بعد** التحديث التفاؤلي للصوت الجديد وتمسحه برجوعها
      // ببيانات قديمة (لسه بتقول «ما صوّت»، لأن الـPOST الجديد لسه ما
      // انبعت وقت ما انطلبت). إعادة التحميل بتصير مرة وحدة بس بآخر
      // الخطوتين، بعد ما `_cast` يخلص.
      final withdrawResult = await _withdraw(current.id, refresh: false);
      if (withdrawResult case Err()) return withdrawResult;

      // العدّاد المرجَّح بعد تبديل بمرحلتين محتاج تصحيح مرة وحدة —
      // `_cast` بيضيف وزن الصوت الجديد بس ما بيطرح وزن الصوت المسحوب
      // (مجهول أصلاً، راجع تعليق `_withdraw`).
      final castResult = await _cast(current.id, value);
      unawaited(_fetch());
      return castResult;
    }

    return _cast(current.id, value);
  }

  Future<void> _fetch() async {
    final result = await _getProjects(const NoParams());

    if (isClosed) return;

    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            status: value.isEmpty ? ProjectsStatus.empty : ProjectsStatus.ready,
            items: value,
          ),
        );

      case Err(:final failure):
        emit(
          state.copyWith(
            status: ProjectsStatus.error,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<Result<void>> _cast(int projectId, bool value) async {
    emit(state.copyWith(votingIds: {...state.votingIds, projectId}));

    final result = await _vote(
      VoteProjectParams(projectId: projectId, value: value),
    );

    if (isClosed) return const Ok(null);

    final remainingVotingIds = {...state.votingIds}..remove(projectId);

    switch (result) {
      case Ok(value: final receipt):
        final current = _findProject(projectId);

        if (current == null) {
          emit(state.copyWith(votingIds: remainingVotingIds));
          return const Ok(null);
        }

        final updated = current.copyWith(
          myReaction: receipt.value
              ? ProjectReaction.favor
              : ProjectReaction.oppose,
          totalVotes: current.totalVotes + 1,
          weightedYesVotes: receipt.value
              ? current.weightedYesVotes + receipt.voteWeight
              : current.weightedYesVotes,
          weightedOpposeVotes: receipt.value
              ? current.weightedOpposeVotes
              : current.weightedOpposeVotes + receipt.voteWeight,
        );

        emit(
          state.copyWith(
            votingIds: remainingVotingIds,
            items: _replace(updated),
          ),
        );

        return const Ok(null);

      case Err(:final failure):
        emit(state.copyWith(votingIds: remainingVotingIds));
        return Err(failure);
    }
  }

  /// `refresh: false` لما `_withdraw` جزء من تبديل حصري (سحب + صوت
  /// جديد فوراً) — المستدعي (`vote`) بيتكفّل بإعادة تحميل وحيدة بعد
  /// ما الخطوتين يخلصوا، بدل ما إعادة تحميل هون تتسابق مع التحديث
  /// التفاؤلي للصوت الجديد.
  Future<Result<void>> _withdraw(int projectId, {bool refresh = true}) async {
    emit(state.copyWith(votingIds: {...state.votingIds, projectId}));

    final result = await _unvote(UnvoteProjectParams(projectId: projectId));

    if (isClosed) return const Ok(null);

    final remainingVotingIds = {...state.votingIds}..remove(projectId);

    switch (result) {
      case Ok():
        final current = _findProject(projectId);

        emit(
          state.copyWith(
            votingIds: remainingVotingIds,
            items: current == null
                ? state.items
                : _replace(current.copyWith(myReaction: ProjectReaction.none)),
          ),
        );

        // ⚠️ العدّاد المرجَّح ما بينتحدّث محلياً هون — `DELETE` بلا
        // استرجاع، وما عنّا وزن صوتنا الأصلي (`GET /votable` ما بيرجّعه
        // كمان). إعادة تحميل صامتة بالخلفية (بلا `status: loading`،
        // فما بتقفل الشاشة) حتى يضل العدّاد دقيق بلا تخمين.
        if (refresh) unawaited(_fetch());

        return const Ok(null);

      case Err(:final failure):
        emit(state.copyWith(votingIds: remainingVotingIds));
        return Err(failure);
    }
  }

  MunicipalProject? _findProject(int id) {
    for (final item in state.items) {
      if (item.id == id) return item;
    }

    return null;
  }

  List<MunicipalProject> _replace(MunicipalProject updated) {
    return [
      for (final item in state.items)
        if (item.id == updated.id) updated else item,
    ];
  }
}
