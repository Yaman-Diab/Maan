// -------------------------
// Profile Stats
// -------------------------

import 'package:equatable/equatable.dart';

/// مستوى المؤشر — مشتق من النسبة لا محفوظ بالباك اند.
enum StatLevel { beginner, intermediate, advanced }

/// مؤشرات المواطن وعدّادات نشاطه.
///
/// ✅ **الكل مؤكّد أخيراً** بمثال استجابة حقيقي لـ`GET /api/profile`:
/// `citizenship_score`/`credibility_score` (راجع `CitizenProfileModel`؛
/// `credibilityIndex` هو «مؤشر المصداقية» لا «مؤشر التوثيق» — الاسم
/// القديم `authenticationIndex` كان تخميناً غلط)، و`volunteering_count`/
/// `total_donated`/`donation_count`. حقل «التراخيص» (`licensesCount`)
/// انحذف كلياً — ما إله عقد باك اند ولا طلب عرض من صاحب المشروع.
final class ProfileStats extends Equatable {
  /// نسبة من 0 لـ100 — `citizenship_score`.
  final int? citizenshipIndex;

  /// نسبة من 0 لـ100 — `credibility_score` («مؤشر المصداقية»).
  final int? credibilityIndex;

  /// `volunteering_count`.
  final int? volunteeringCount;

  /// `donation_count`.
  final int? donationCount;

  /// `total_donated` — مبلغ، فبيضل `num` لا `int` حتى لا يخسر كسوراً.
  final num? totalDonated;

  const ProfileStats({
    this.citizenshipIndex,
    this.credibilityIndex,
    this.volunteeringCount,
    this.donationCount,
    this.totalDonated,
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
    donationCount,
    totalDonated,
  ];
}
