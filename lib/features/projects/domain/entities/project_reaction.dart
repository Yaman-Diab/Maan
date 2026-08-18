// -------------------------
// Project Reaction
// -------------------------

/// رأي المستخدم بمشروع — مشتق من `has_voted`/`my_vote` الراجعين من
/// `GET /api/project/votable`.
///
/// ⚠️ **قفل بمجرّد الإرسال — لا تبديل ولا إلغاء** — عكس الافتراض
/// الأولي (تصويت حصري قابل للتبديل بلا حد): `POST /api/project/vote/{id}`
/// **بلا endpoint لتغيير أو حذف تصويت قائم**، ومحاولة تصويت ثانية
/// (حتى لو نفس القيمة) بترجع `409`. يعني بمجرّد ما `myReaction` تصير
/// [favor] أو [oppose]، الزرّين لازم يتقفلوا نهائياً — لا يعتمد على
/// إعادة الضغط لإلغاء الرأي.
enum ProjectReaction {
  none(''),
  favor('favor'),
  oppose('oppose');

  const ProjectReaction(this.wireValue);

  final String wireValue;

  /// بيبني الحالة من زوج `has_voted`/`my_vote` — لا من نص واحد
  /// (الباك اند ما بيرجّع حقل نصّي موحّد لهالمفهوم).
  static ProjectReaction fromVoteFields({
    required bool hasVoted,
    required bool? myVote,
  }) {
    if (!hasVoted) return ProjectReaction.none;
    // ⚠️ `has_voted: true` بلا `my_vote` واضح حالة مشوَّهة نظرياً —
    // بنرجع `none` بدل تخمين قيمة ثابتة، حتى الأزرار تضل مفعّلة
    // (أسوأ سيناريو 409 بيتعامل معه الـCubit) بدل ما نقفل بقيمة غلط.
    if (myVote == null) return ProjectReaction.none;

    return myVote ? ProjectReaction.favor : ProjectReaction.oppose;
  }
}
