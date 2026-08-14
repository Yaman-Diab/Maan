// -------------------------
// Verification Request Status
// -------------------------

/// حالة **طلب التوثيق نفسه** — غير `AccountStatus` (حالة الحساب العامة
/// بـ`core/session/`). الطلب بيبدأ `pending`، والباك اند لاحقاً بيغيّر
/// `AccountStatus` تبع المستخدم (verified/closed) بعد المراجعة.
///
/// ✅ **الثلاث قيم مؤكّدة بالكامل** — مصدرها enum الباك اند الحقيقي
/// (`App\Enums\VerificationStatus`): `pending` · `approved` · `rejected`
/// حرفياً، بلا مرادفات. أي قيمة تانية (أو غياب الحقل) بترجع [unknown] —
/// والواجهة بتعامله كـ«ما في طلب فعّال» فتعرض النموذج، وهو أأمن سلوك
/// ممكن: المستخدم بيقدر يقدّم طلب، بدل ما تعلق الشاشة على حالة ما
/// بتنعرف (مثلاً حالة رابعة يضيفها الباك اند مستقبلاً).
enum VerificationRequestStatus {
  pending,
  approved,
  rejected,
  unknown;

  bool get isPending => this == VerificationRequestStatus.pending;

  bool get isApproved => this == VerificationRequestStatus.approved;

  bool get isRejected => this == VerificationRequestStatus.rejected;

  static VerificationRequestStatus fromApi(String? value) {
    return switch (value) {
      'pending' => VerificationRequestStatus.pending,
      'approved' => VerificationRequestStatus.approved,
      'rejected' => VerificationRequestStatus.rejected,
      _ => VerificationRequestStatus.unknown,
    };
  }
}
