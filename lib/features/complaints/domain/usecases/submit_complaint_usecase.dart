// -------------------------
// Submit Complaint Use Case
// -------------------------

import '../../../../core/media/picked_complaint_media.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/complaint_category.dart';
import '../entities/complaint_type.dart';
import '../repositories/complaints_repository.dart';

class SubmitComplaintParams {
  final ComplaintType type;
  final ComplaintCategory category;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final List<PickedComplaintMedia> media;

  const SubmitComplaintParams({
    required this.type,
    required this.category,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    this.media = const [],
  });
}

class SubmitComplaintUseCase implements UseCase<void, SubmitComplaintParams> {
  final ComplaintsRepository _repository;

  const SubmitComplaintUseCase(this._repository);

  @override
  Future<Result<void>> call(SubmitComplaintParams params) {
    return _repository.submit(
      type: params.type,
      category: params.category,
      title: params.title,
      description: params.description,
      latitude: params.latitude,
      longitude: params.longitude,
      media: params.media,
    );
  }
}
