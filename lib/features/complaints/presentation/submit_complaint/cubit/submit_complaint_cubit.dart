// -------------------------
// Submit Complaint Cubit
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/location/location_service.dart';
import '../../../../../core/media/picked_complaint_media.dart';
import '../../../../../core/result/result.dart';
import '../../../domain/entities/complaint_category.dart';
import '../../../domain/entities/complaint_type.dart';
import '../../../domain/usecases/submit_complaint_usecase.dart';
import 'submit_complaint_state.dart';

class SubmitComplaintCubit extends Cubit<SubmitComplaintState> {
  final SubmitComplaintUseCase _submitComplaint;
  final LocationService _locationService;

  SubmitComplaintCubit(this._submitComplaint, this._locationService)
    : super(const SubmitComplaintState());

  void typeChanged(ComplaintType type) {
    emit(state.copyWith(type: type));
  }

  void categoryChanged(ComplaintCategory category) {
    emit(state.copyWith(category: category));
  }

  void titleChanged(String value) {
    emit(state.copyWith(title: value));
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(description: value));
  }

  Future<void> useCurrentLocation() async {
    emit(state.copyWith(isLocating: true, clearLocationError: true));

    try {
      final location = await _locationService.getCurrentLocation();

      if (isClosed) return;

      emit(
        state.copyWith(
          isLocating: false,
          latitude: location.latitude,
          longitude: location.longitude,
        ),
      );
    } on LocationServiceException catch (exception) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isLocating: false,
          locationErrorMessage: switch (exception.reason) {
            LocationFailureReason.serviceDisabled =>
              'complaint_location_service_disabled'.tr(),
            LocationFailureReason.permissionDenied =>
              'complaint_location_permission_denied'.tr(),
          },
        ),
      );
    }
  }

  void addMedia(PickedComplaintMedia item) {
    if (state.media.length >= SubmitComplaintState.maxMediaCount) return;

    emit(state.copyWith(media: [...state.media, item]));
  }

  void removeMediaAt(int index) {
    final media = [...state.media]..removeAt(index);
    emit(state.copyWith(media: media));
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    final description = state.description.trim();

    final result = await _submitComplaint(
      SubmitComplaintParams(
        type: state.type,
        category: state.category!,
        title: state.title.trim(),
        description: description.isEmpty ? null : description,
        latitude: state.latitude!,
        longitude: state.longitude!,
        media: state.media,
      ),
    );

    if (isClosed) return;

    switch (result) {
      case Ok():
        emit(state.copyWith(isSubmitting: false, submitted: true));

      case Err(:final failure):
        emit(
          state.copyWith(isSubmitting: false, errorMessage: failure.message),
        );
    }
  }
}
