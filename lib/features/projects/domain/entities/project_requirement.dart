// -------------------------
// Project Requirement
// -------------------------

import 'package:equatable/equatable.dart';

/// متطلّب مهارة واحد ضمن مشروع — من `requirements[]` بـ
/// `GET /api/project/{id}`.
///
/// ✅ **مؤكّد بمثال استجابة حقيقي**. بديل أدقّ من الرقم الإجمالي
/// [MunicipalProject.volunteersNeeded]/[MunicipalProject.volunteersApproved]
/// — بيبيّن أي مهارة بالضبط لسه ناقصة، لا رقم مجمّع بلا تفصيل.
final class ProjectRequirement extends Equatable {
  final int id;
  final String skillName;
  final String? skillType;
  final int requiredCount;
  final bool isNeedCertificate;
  final int approvedCount;
  final int remainingCount;

  const ProjectRequirement({
    required this.id,
    required this.skillName,
    this.skillType,
    this.requiredCount = 0,
    this.isNeedCertificate = false,
    this.approvedCount = 0,
    this.remainingCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    skillName,
    skillType,
    requiredCount,
    isNeedCertificate,
    approvedCount,
    remainingCount,
  ];
}
