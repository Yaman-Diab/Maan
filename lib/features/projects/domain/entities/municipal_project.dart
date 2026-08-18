// -------------------------
// Municipal Project
// -------------------------

import 'package:equatable/equatable.dart';

import 'project_donation_stats.dart';
import 'project_reaction.dart';

/// مشروع بلدي منشور للمواطنين، من `GET /api/project/votable`.
///
/// ⚠️ **بس المشاريع القابلة للتصويت بتوصل هون** — دورة الحياة بالباك
/// اند (`Draft → Pending Review → Approved → Submitted → ...`) كلها
/// إدارية، وهالـendpoint تحديداً بيرجّع مرحلة «قابل للتصويت» بس.
/// راجع `ApiEndpoints.projectVotable` لتفاصيل الغموض حول اكتمال
/// حقول المشروع (وصف/صورة/تطوّع) بهالاستجابة تحديداً.
final class MunicipalProject extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  /// عدد المتطوعين **المطلوب** — لا عدد المتقدّمين ولا المقبولين.
  ///
  /// ⚠️ ما في «X من Y» ولا نسبة إنجاز عن قصد: أي مواطن موثّق بيقدر
  /// يقدّم طلب تطوع، وموظّف البلدية هو يلي بيراجع ويوافق لاحقاً — فما
  /// في رقم «صار موجود» نقدر نعرضه بثقة. `null` = المشروع ما بده تطوع.
  final int? volunteersNeeded;

  final bool requiresDonations;

  /// ✅ **إحصائيات التصويت مؤكّدة بالكامل** من `GET /api/project/votable`
  /// — مرجَّحة بمؤشّر مواطنة الناخب (`vote_weight` وقت التصويت)، لا
  /// عدّ رؤوس بسيط. `totalVotes` عدد الأصوات الخام (أحبذ + لا أحبذ)،
  /// و`weightedYesVotes`/`weightedOpposeVotes` مجموع الأوزان لكل جهة.
  final int totalVotes;
  final double weightedYesVotes;
  final double weightedOpposeVotes;

  /// رأي المستخدم الحالي — مشتق من `has_voted`/`my_vote`، **قفل بمجرّد
  /// التصويت** (راجع تحذير [ProjectReaction]).
  final ProjectReaction myReaction;

  /// إحصائيات التبرعات — بتنجلب من endpoint **منفصل** لكل مشروع
  /// (`GET /api/project/{id}/donations/stats`) وبتنضم هون بطبقة data،
  /// نفس نمط دمج الشهادات بالمهارات (`SkillsRepositoryImpl`).
  ///
  /// ⚠️ `null` معناها **ما انجلبت أو فشل جلبها**، لا «ما في تبرعات» —
  /// فشل الإحصائيات بيخفي شريط التقدّم بس وما بيكسر بطاقة المشروع ولا
  /// القائمة. المشاريع بلا `requiresDonations` ما بتنجلب إحصائياتها
  /// أصلاً (توفير طلبات).
  final ProjectDonationStats? donationStats;

  const MunicipalProject({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.volunteersNeeded,
    this.requiresDonations = false,
    this.totalVotes = 0,
    this.weightedYesVotes = 0,
    this.weightedOpposeVotes = 0,
    this.myReaction = ProjectReaction.none,
    this.donationStats,
  });

  bool get requiresVolunteers =>
      volunteersNeeded != null && volunteersNeeded! > 0;

  bool get hasLocation => latitude != null && longitude != null;

  /// بطاقة بلا تطوع ولا تبرع ما بتعرض صف الأزرار أصلاً.
  bool get hasActions => requiresVolunteers || requiresDonations;

  bool get hasVoted => myReaction != ProjectReaction.none;

  MunicipalProject copyWith({
    double? weightedYesVotes,
    double? weightedOpposeVotes,
    int? totalVotes,
    ProjectReaction? myReaction,
    ProjectDonationStats? donationStats,
  }) {
    return MunicipalProject(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      latitude: latitude,
      longitude: longitude,
      volunteersNeeded: volunteersNeeded,
      requiresDonations: requiresDonations,
      totalVotes: totalVotes ?? this.totalVotes,
      weightedYesVotes: weightedYesVotes ?? this.weightedYesVotes,
      weightedOpposeVotes: weightedOpposeVotes ?? this.weightedOpposeVotes,
      myReaction: myReaction ?? this.myReaction,
      donationStats: donationStats ?? this.donationStats,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imageUrl,
    latitude,
    longitude,
    volunteersNeeded,
    requiresDonations,
    totalVotes,
    weightedYesVotes,
    weightedOpposeVotes,
    myReaction,
    donationStats,
  ];
}
