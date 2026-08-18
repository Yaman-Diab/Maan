// -------------------------
// Project Donation Stats
// -------------------------

import 'package:equatable/equatable.dart';

/// إحصائيات تبرعات مشروع — من `GET /api/project/{id}/donations/stats`.
///
/// ✅ **مؤكّدة بالكامل** (الحقول الخمسة + سلوك الحواف) من الباك اند
/// مباشرة (`ProjectDonationService`).
final class ProjectDonationStats extends Equatable {
  /// مجموع التبرعات الفعلية بالفلوس — **لا عدد المتبرعين**. النسبة
  /// المئوية محسوبة منه هو، لا من [numberOfDonors].
  final num totalDonated;

  /// الهدف = `budget` تبع المشروع. ⚠️ **`null` لو المشروع بلا ميزانية
  /// محدّدة** — حالة حقيقية لا خطأ، والواجهة لازم تتعامل معها (بلا
  /// شريط تقدّم أصلاً، راجع [hasTarget]).
  final num? donationTarget;

  /// الهدف ناقص المجموع، **محدود بصفر** من الباك اند (`max(..., 0)`)
  /// فما بيصير سالباً لو التبرعات تخطّت الهدف. `null` مع [donationTarget].
  final num? remainingAmount;

  /// ⚠️ **محدودة بـ100** من الباك اند (`min(..., 100)`) حتى لو المجموع
  /// تخطّى الهدف، و**بترجع `0` لو ما في هدف محدّد** — فصفر هون معناه
  /// «ما في هدف» أو «ما في تبرعات»، والتفريق بينهم عبر [hasTarget] لا
  /// عبر النسبة نفسها.
  final int donationPercentage;

  final int numberOfDonors;

  const ProjectDonationStats({
    required this.totalDonated,
    this.donationTarget,
    this.remainingAmount,
    this.donationPercentage = 0,
    this.numberOfDonors = 0,
  });

  /// في هدف حقيقي نقدر نرسم شريط تقدّم عليه.
  ///
  /// `> 0` لا `!= null` بس: هدف بصفر بيخلّي النسبة قسمة على صفر
  /// منطقياً، وشريط تقدّم عليه بلا معنى.
  bool get hasTarget => donationTarget != null && donationTarget! > 0;

  /// وصل الهدف أو تخطّاه — الشريط بيتلوّن أخضر بدل الكهرماني.
  bool get isFunded => hasTarget && donationPercentage >= 100;

  @override
  List<Object?> get props => [
    totalDonated,
    donationTarget,
    remainingAmount,
    donationPercentage,
    numberOfDonors,
  ];
}
