// -------------------------
// Skills State
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../domain/entities/certificate_status.dart';
import '../../../domain/entities/skill.dart';

enum SkillsStatus { loading, empty, error, ready }

final class SkillsState extends Equatable {
  final SkillsStatus status;
  final List<Skill> skills;
  final String? errorMessage;

  const SkillsState({
    this.status = SkillsStatus.loading,
    this.skills = const [],
    this.errorMessage,
  });

  int get approvedCount => skills
      .where((s) => s.certificate?.status == CertificateStatus.approved)
      .length;

  int get pendingCount => skills
      .where((s) => s.certificate?.status == CertificateStatus.pending)
      .length;

  int get noCertificateCount =>
      skills.where((s) => s.certificate == null).length;

  bool get hasPendingCertificate => pendingCount > 0;

  SkillsState copyWith({
    SkillsStatus? status,
    List<Skill>? skills,
    String? errorMessage,
  }) {
    return SkillsState(
      status: status ?? this.status,
      skills: skills ?? this.skills,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, skills, errorMessage];
}
