// -------------------------
// Municipal Project
// -------------------------

import 'package:equatable/equatable.dart';

import 'project_donation_stats.dart';
import 'project_reaction.dart';
import 'project_requirement.dart';

/// مشروع بلدي منشور للمواطنين — مدموج من مسارين.
///
/// ✅ **`GET /api/project/votable` مؤكّد بالكامل بمثال حقيقي** (`id`/
/// `name`/`description`/`user`/`voting_status`/`voting_ends_at` + كل
/// حقول التصويت). بيّن الشكل الحقيقي **غياب قاطع** لـ`image`/
/// `location`/`is_voluntary`/`is_donation` — مش تخمين ناقص، الحقول
/// مش موجودة إطلاقاً بهالمسار (مؤكّد من كود الباك اند نفسه:
/// `ProjectVoteService::listVotable()` بيبني مصفوفة استجابة يدوية
/// بـ13 مفتاح محدَّد بالضبط، بلا أي حقل تاني).
///
/// ✅ **الحقول الناقصة مصدرها `GET /api/project/{id}` (`show`) —
/// مؤكّد citizen-accessible من `UserSeeder.php`** (`project.show` ضمن
/// صلاحيات المواطن). `ProjectsRepositoryImpl.getProjects` بيجلبه لكل
/// مشروع بالتوازي (نفس نمط إحصائيات التبرعات) وبيدمج `imageUrl`/
/// `latitude`/`longitude`/`requiresVolunteers`/`requiresDonations`/
/// `volunteersNeeded`/`type`/`status`/`isVotable`/`budget`/`requirements`
/// فيه. راجع `ProjectService::formatProject` بالباك اند للمصدر الدقيق.
///
/// ❌ **`ownerName`/`ownerAvatarUrl` (بيانات صاحب/ناشر المشروع) انحذفوا
/// كلياً** — طلب صريح من صاحب المشروع: البطاقة بتعرض معلومات المشروع
/// نفسه بس، لا مين نشره. الدائرة يلي كانت تعرض صورة الناشر بأعلى
/// البطاقة (`_OwnerAvatar`) صارت تعرض [imageUrl] (صورة المشروع نفسه من
/// `media[]`) بدلاً منها — كانت مقروءة أصلاً بس غير معروضة بأي مكان.
final class MunicipalProject extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  /// ⚠️ **قيمة وحيدة مؤكّدة لحد الآن (`"municipal"`)** — نفس معاملة
  /// [votingStatus]: مخزَّن خام بلا منطق عرض عليه لحد ما يوصل مثال
  /// لقيمة تانية.
  final String? type;

  /// حالة المشروع بدورة حياته (`"submitted"` بالمثال المؤكّد الوحيد) —
  /// **مختلفة عن** [votingStatus] (حالة التصويت). نفس معاملة [type]:
  /// مخزَّنة خام بلا شارة عرض بعد لحد ما توصل أمثلة لقيم تانية (موافق
  /// عليه/مرفوض...). سبب الرفض (`rejection_reason`) عمداً **ما انقرأ
  /// أصلاً** — طلب صريح من صاحب المشروع إنه مالوش شغل بواجهة المواطن.
  final String? status;

  /// `is_votable` — إشارة خام من الباك اند، **غير مستهلَكة بعد**: عرض
  /// أزرار التصويت متحكَّم فيه حالياً عبر `onReactionTap` (الشاشة
  /// الحاضنة بتقرّره)، وربطه بهالحقل قرار عرض منفصل يحتاج تأكيد قبل
  /// ما يبدّل سلوك قائم.
  final bool? isVotable;

  /// ميزانية المشروع الخام (`budget`) — **مخزَّنة بس مش معروضة لحالها**:
  /// نفس القيمة تماماً بتوصل كـ[ProjectDonationStats.donationTarget] من
  /// `GET /api/project/{id}/donations/stats` (مؤكّد من الباك اند: الهدف
  /// = `budget` تبع المشروع)، فعرضها هون كمان بيكرّر شريط التبرعات بلا
  /// فايدة إضافية.
  final num? budget;

  /// تفصيل كل مهارة مطلوبة على حدة — بديل [volunteersNeeded]/
  /// [volunteersApproved] المجمّعين لما نحتاج نعرض «شو بالضبط لسه
  /// ناقص» لا رقم إجمالي مبهم. فاضية افتراضياً (القائمة `votable` ما
  /// بترجّعها، ومشروع بلا `requirements` بالتفاصيل حالة حقيقية).
  final List<ProjectRequirement> requirements;

  /// ⚠️ **قيمة وحيدة مؤكّدة لحد الآن (`"active"`)** — ما في مثال لحالة
  /// تانية، فما بنبني عليها منطق عرض/إخفاء أزرار بعد. مخزَّنة خام
  /// جاهزة لو ظهرت قيم تانية.
  final String? votingStatus;

  /// موعد انتهاء التصويت — `null` لمشروع بلا موعد محدّد (شفناها
  /// بمثالين حقيقيين من التلاتة).
  final DateTime? votingEndsAt;

  /// ✅ نسبة القبول (`weighted_yes / total_weighted × 100`، محسوبة من
  /// الباك اند) — كانت موثّقة كـ«غير مستهلَكة» قبل ما نتأكّد من
  /// الاستجابة الكاملة؛ صارت مستهلَكة هلأ.
  final int? approvalPercentage;

  /// ✅ **من `GET /api/project/{id}`** (`is_voluntary` بقاعدة البيانات)
  /// — إشارة حقيقية موثوقة، لا تخمين. `false` افتراضياً لحد ما يوصل
  /// تفاصيل المشروع (يعني الزر بيتعطّل مؤقّتاً وقت التحميل الأول، لا
  /// خطأ).
  final bool requiresVolunteers;

  /// عدد المتطوعين **المطلوب** — مجموع `required_count` عبر كل متطلّب
  /// مهارة (`total_required_volunteers` بالباك اند)، لا رقم مفرد.
  ///
  /// ⚠️ ما في «X من Y» ولا نسبة إنجاز بالواجهة عمداً رغم إن الباك اند
  /// **بيرجّع فعلياً** `total_approved_volunteers` (راجع
  /// [volunteersApproved]) — قرار عرض صريح لا فجوة بيانات، غير
  /// مرتبط بتوفّر الرقم.
  final int? volunteersNeeded;

  /// ✅ **متوفّر من الباك اند بس غير مستهلَك بالواجهة عمداً** — راجع
  /// تحذير [volunteersNeeded]. مخزَّن جاهز لو تغيّر قرار العرض
  /// مستقبلاً.
  final int? volunteersApproved;

  /// ✅ **من `GET /api/project/{id}`** (`is_donation` بقاعدة البيانات).
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
  /// القائمة.
  final ProjectDonationStats? donationStats;

  const MunicipalProject({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.type,
    this.status,
    this.isVotable,
    this.budget,
    this.requirements = const [],
    this.votingStatus,
    this.votingEndsAt,
    this.approvalPercentage,
    this.requiresVolunteers = false,
    this.volunteersNeeded,
    this.volunteersApproved,
    this.requiresDonations = false,
    this.totalVotes = 0,
    this.weightedYesVotes = 0,
    this.weightedOpposeVotes = 0,
    this.myReaction = ProjectReaction.none,
    this.donationStats,
  });

  bool get hasLocation => latitude != null && longitude != null;

  bool get hasVoted => myReaction != ProjectReaction.none;

  MunicipalProject copyWith({
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? type,
    String? status,
    bool? isVotable,
    num? budget,
    List<ProjectRequirement>? requirements,
    bool? requiresVolunteers,
    int? volunteersNeeded,
    int? volunteersApproved,
    bool? requiresDonations,
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
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      status: status ?? this.status,
      isVotable: isVotable ?? this.isVotable,
      budget: budget ?? this.budget,
      requirements: requirements ?? this.requirements,
      votingStatus: votingStatus,
      votingEndsAt: votingEndsAt,
      approvalPercentage: approvalPercentage,
      requiresVolunteers: requiresVolunteers ?? this.requiresVolunteers,
      volunteersNeeded: volunteersNeeded ?? this.volunteersNeeded,
      volunteersApproved: volunteersApproved ?? this.volunteersApproved,
      requiresDonations: requiresDonations ?? this.requiresDonations,
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
    type,
    status,
    isVotable,
    budget,
    requirements,
    votingStatus,
    votingEndsAt,
    approvalPercentage,
    requiresVolunteers,
    volunteersNeeded,
    volunteersApproved,
    requiresDonations,
    totalVotes,
    weightedYesVotes,
    weightedOpposeVotes,
    myReaction,
    donationStats,
  ];
}
