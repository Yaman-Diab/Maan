// -------------------------
// Profile Stats
// -------------------------

import 'package:equatable/equatable.dart';

/// مستوى المؤشر — مشتق من النسبة لا محفوظ بالباك اند.
enum StatLevel { beginner, intermediate, advanced }

/// مؤشرات المواطن وعدّادات نشاطه.
///
/// ✅ **`citizenshipIndex`/`credibilityIndex` مؤكّدان أخيراً** بمثال
/// استجابة حقيقي لـ`GET /api/profile` (`citizenship_score` و
/// `credibility_score`) — راجع `CitizenProfileModel`. `credibilityIndex`
/// هو «مؤشر المصداقية» لا «مؤشر التوثيق»: الاسم القديم
/// `authenticationIndex` كان تخميناً غلط قبل وصول المثال الحقيقي.
///
/// ⚠️ العدّادات التلاتة (تطوّع/مساهمات/تراخيص) لسه بلا عقد — `null`
/// قابلة للقراءة لو أضافهم `/api/profile` لاحقاً، والواجهة بتعرض «—»
/// بدل رقم مخترع لحد ما توصل.
final class ProfileStats extends Equatable {
  /// نسبة من 0 لـ100 — `citizenship_score`.
  final int? citizenshipIndex;

  /// نسبة من 0 لـ100 — `credibility_score` («مؤشر المصداقية»).
  final int? credibilityIndex;

  final int? volunteeringCount;
  final int? contributionsCount;
  final int? licensesCount;

  const ProfileStats({
    this.citizenshipIndex,
    this.credibilityIndex,
    this.volunteeringCount,
    this.contributionsCount,
    this.licensesCount,
  });

  /// اللي بترجّعه الواجهة لحد ما يجهّز الباك اند الحقول.
  static const ProfileStats empty = ProfileStats();

  bool get isEmpty => this == empty;

  /// نفس عتبات التصميم: 75 فما فوق متقدّم، و40 فما فوق متوسط.
  static StatLevel levelOf(int percentage) {
    if (percentage >= 75) return StatLevel.advanced;
    if (percentage >= 40) return StatLevel.intermediate;

    return StatLevel.beginner;
  }

  @override
  List<Object?> get props => [
    citizenshipIndex,
    credibilityIndex,
    volunteeringCount,
    contributionsCount,
    licensesCount,
  ];
}
