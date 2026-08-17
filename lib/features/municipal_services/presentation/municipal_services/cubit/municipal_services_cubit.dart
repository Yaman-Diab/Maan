// -------------------------
// Municipal Services Cubit
// -------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/result/result.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/get_municipal_services_usecase.dart';
import 'municipal_services_state.dart';

class MunicipalServicesCubit extends Cubit<MunicipalServicesState> {
  final GetMunicipalServicesUseCase _getServices;

  MunicipalServicesCubit(this._getServices)
    : super(const MunicipalServicesState());

  Future<void> load() async {
    emit(state.copyWith(status: MunicipalServicesStatus.loading));

    final result = await _getServices(const NoParams());

    if (isClosed) return;

    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            status: value.isEmpty
                ? MunicipalServicesStatus.empty
                : MunicipalServicesStatus.ready,
            services: value,
          ),
        );

      case Err(:final failure):
        emit(
          state.copyWith(
            status: MunicipalServicesStatus.error,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
