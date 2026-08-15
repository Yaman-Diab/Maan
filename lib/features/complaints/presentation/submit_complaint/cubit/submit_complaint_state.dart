// -------------------------
// Submit Complaint State
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../../core/media/picked_complaint_media.dart';
import '../../../domain/entities/complaint_category.dart';
import '../../../domain/entities/complaint_type.dart';

final class SubmitComplaintState extends Equatable {
  final ComplaintType type;
  final ComplaintCategory? category;
  final String title;
  final String description;
  final double? latitude;
  final double? longitude;
  final bool isLocating;
  final String? locationErrorMessage;
  final List<PickedComplaintMedia> media;
  final bool isSubmitting;
  final String? errorMessage;
  final bool submitted;

  const SubmitComplaintState({
    this.type = ComplaintType.individual,
    this.category,
    this.title = '',
    this.description = '',
    this.latitude,
    this.longitude,
    this.isLocating = false,
    this.locationErrorMessage,
    this.media = const [],
    this.isSubmitting = false,
    this.errorMessage,
    this.submitted = false,
  });

  bool get isEmergency => type == ComplaintType.emergency;

  bool get hasLocation => latitude != null && longitude != null;

  static const int maxMediaCount = 6;

  bool get canSubmit {
    if (isSubmitting) return false;
    if (category == null || title.trim().isEmpty || !hasLocation) return false;
    if (!isEmergency && description.trim().isEmpty) return false;

    return true;
  }

  SubmitComplaintState copyWith({
    ComplaintType? type,
    ComplaintCategory? category,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    bool? isLocating,
    String? locationErrorMessage,
    bool clearLocationError = false,
    List<PickedComplaintMedia>? media,
    bool? isSubmitting,
    String? errorMessage,
    bool? submitted,
  }) {
    return SubmitComplaintState(
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLocating: isLocating ?? this.isLocating,
      locationErrorMessage: clearLocationError
          ? null
          : (locationErrorMessage ?? this.locationErrorMessage),
      media: media ?? this.media,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      submitted: submitted ?? this.submitted,
    );
  }

  @override
  List<Object?> get props => [
    type,
    category,
    title,
    description,
    latitude,
    longitude,
    isLocating,
    locationErrorMessage,
    media,
    isSubmitting,
    errorMessage,
    submitted,
  ];
}
