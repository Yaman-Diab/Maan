// -------------------------
// Skills Cubit
// -------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/result/result.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/get_skills_usecase.dart';
import 'skills_state.dart';

class SkillsCubit extends Cubit<SkillsState> {
  final GetSkillsUseCase _getSkills;

  SkillsCubit(this._getSkills) : super(const SkillsState());

  Future<void> load() async {
    emit(state.copyWith(status: SkillsStatus.loading));

    final result = await _getSkills(const NoParams());

    if (isClosed) return;

    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            status: value.isEmpty ? SkillsStatus.empty : SkillsStatus.ready,
            skills: value,
          ),
        );

      case Err(:final failure):
        emit(
          state.copyWith(
            status: SkillsStatus.error,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
