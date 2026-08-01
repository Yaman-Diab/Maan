// -------------------------
// Profile Stats
// -------------------------

import 'package:equatable/equatable.dart';

/// مستوى المؤشر — مشتق من النسبة لا محفوظ بالباك اند.
enum StatLevel { beginner, intermediate, advanced }

/// مؤشرات المواطن وعدّادات نشاطه.
///
/// ⚠️ **ولا حقل من هدول مؤكّد بعقد الباك اند.** التصميم بيعرضهم، بس
/// `collection.md` ما بيوثّق أي endpoint بيرجّعهم. فكلهم `null` قابلة
/// للقراءة لو أضافهم `/api/profile` لاحقاً، والواجهة بتعرض «—» بدل رقم
/// مخترع لحد ما يوصلوا.
///
/// المفاتيح المتوقّعة موثّقة بـ`ProfileStatsModel` — لما يثبّت الباك اند
/// أسماءه الحقيقية، التعديل بملف واحد.
final class ProfileStats extends Equatable {
  /// نسبة من 0 لـ100.
  final int? citizenshipIndex;

  /// نسبة من 0 لـ100.
  final int? authenticationIndex;

  final int? volunteeringCount;
  final int? contributionsCount;
  final int? licensesCount;

  const ProfileStats({
    this.citizenshipIndex,
    this.authenticationIndex,
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
    authenticationIndex,
    volunteeringCount,
    contributionsCount,
    licensesCount,
  ];
}
