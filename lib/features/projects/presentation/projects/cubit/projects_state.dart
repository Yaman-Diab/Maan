// -------------------------
// Projects State
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../domain/entities/municipal_project.dart';

enum ProjectsStatus { loading, empty, error, ready }

final class ProjectsState extends Equatable {
  final ProjectsStatus status;
  final List<MunicipalProject> items;
  final String? errorMessage;

  /// الحساب موثّق — التطوّع والتصويت محجوزان للموثّقين.
  final bool canParticipate;

  /// معرّفات المشاريع يلي عندها طلب تصويت شغّال هلأ — الزرّين بيتعطّلوا
  /// وبيبيّنوا مؤشّر تحميل لحد ما يوصل ردّ السيرفر (نجاح أو فشل).
  final Set<int> votingIds;

  const ProjectsState({
    this.status = ProjectsStatus.loading,
    this.items = const [],
    this.errorMessage,
    this.canParticipate = false,
    this.votingIds = const {},
  });

  ProjectsState copyWith({
    ProjectsStatus? status,
    List<MunicipalProject>? items,
    String? errorMessage,
    bool? canParticipate,
    Set<int>? votingIds,
  }) {
    return ProjectsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      canParticipate: canParticipate ?? this.canParticipate,
      votingIds: votingIds ?? this.votingIds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    errorMessage,
    canParticipate,
    votingIds,
  ];
}
