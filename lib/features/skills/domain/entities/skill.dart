// -------------------------
// Skill
// -------------------------

import 'package:equatable/equatable.dart';

import 'certificate.dart';
import 'skill_type.dart';

/// مهارة مواطن — قائمة بذاتها لحد ما ترتبط بشهادة إثبات اختيارية.
///
/// ⚠️ **المهارة والشهادة موردان منفصلان بالباك اند** (`/api/skill/` و
/// `/api/certificate` كل وحدة عندها CRUD مستقل)، مرتبطان بحقل
/// `user_skill_id` بجسم الشهادة. [certificate] هون **مضاف بطبقة data**
/// بدمج استجابتَي القائمتين — مش حقل حقيقي براجع من `/api/skill/`.
final class Skill extends Equatable {
  final int id;
  final String name;
  final SkillType type;
  final DateTime? createdAt;

  /// `null` = مهارة معلَنة ذاتياً، بلا شهادة إثبات بعد. مسموح ومقصود —
  /// التقديم للفرص التطوعية ما بيعتمد على وجودها.
  final Certificate? certificate;

  const Skill({
    required this.id,
    required this.name,
    required this.type,
    this.createdAt,
    this.certificate,
  });

  @override
  List<Object?> get props => [id, name, type, createdAt, certificate];
}
