// -------------------------
// Project Vote Receipt
// -------------------------

import 'package:equatable/equatable.dart';

/// تأكيد التصويت الراجع من `POST /api/project/vote/{id}`.
///
/// ✅ الشكل مؤكّد بمثال استجابة حقيقي (`201`). `voteWeight` محسوب من
/// الباك اند بناءً على `citizenship_score_at_vote_time` — القيمة
/// الوحيدة يلي فيها معنى نستخدمها لتحديث العدّاد المرجَّح محلياً بدل
/// ما نخمّنها قبل ما السيرفر يردّ.
final class ProjectVoteReceipt extends Equatable {
  final int projectId;
  final bool value;
  final double voteWeight;
  final double citizenshipScoreAtVoteTime;

  const ProjectVoteReceipt({
    required this.projectId,
    required this.value,
    required this.voteWeight,
    required this.citizenshipScoreAtVoteTime,
  });

  @override
  List<Object?> get props => [
    projectId,
    value,
    voteWeight,
    citizenshipScoreAtVoteTime,
  ];
}
