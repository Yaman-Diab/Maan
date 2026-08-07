// -------------------------
// Verification Request Status
// -------------------------

/// حالة **طلب التوثيق نفسه** — غير `AccountStatus` (حالة الحساب العامة
/// بـ`core/session/`). الطلب بيبدأ `pending`، والباك اند لاحقاً بيغيّر
/// `AccountStatus` تبع المستخدم (verified/blocked) بعد المراجعة.
///
/// ⚠️ **`pending` هي القيمة الوحيدة المؤكّدة** — من استجابة
/// `POST /api/verification/store` الحقيقية. [approved] و[rejected]
/// **قيمهما على السلك مخمَّنة**: التصميم بيتطلّب الحالتين، والباك اند
/// عنده فعلاً `GET /api/verification/approve/{id}` و
/// `POST /api/verification/reject/{id}` (قسم verification/admin
/// بـ`collection.md`)، فوجود الحالتين مؤكّد — بس **الاسم النصّي** اللي
/// بيرجع فيهما بالقراءة لا.
///
/// لهيك [fromApi] بتقبل أكتر من مرادف شائع لكل حالة بدل ما تراهن على
/// واحد، وأي قيمة مجهولة بترجع [unknown] — والواجهة بتعامل [unknown]
/// كـ«ما في طلب فعّال» فتعرض النموذج، وهو أأمن سلوك ممكن: المستخدم
/// بيقدر يقدّم طلب، بدل ما تعلق الشاشة على حالة ما بتنعرف.
///
/// نقطة التصحيح الوحيدة لما تتأكّد الأسماء: [_synonyms] تحت.
enum VerificationRequestStatus {
  pending,
  approved,
  rejected,
  unknown;

  /// مرادفات كل حالة كما ممكن ترجع من الباك اند. `pending` وحدها
  /// مؤكّدة؛ الباقي تخمين موثّق — راجع تعليق الـ enum فوق.
  static const Map<VerificationRequestStatus, List<String>> _synonyms = {
    VerificationRequestStatus.pending: ['pending'],
    VerificationRequestStatus.approved: ['approved', 'accepted', 'verified'],
    VerificationRequestStatus.rejected: ['rejected', 'refused', 'declined'],
  };

  bool get isPending => this == VerificationRequestStatus.pending;

  bool get isApproved => this == VerificationRequestStatus.approved;

  bool get isRejected => this == VerificationRequestStatus.rejected;

  static VerificationRequestStatus fromApi(String? value) {
    if (value == null || value.isEmpty) {
      return VerificationRequestStatus.unknown;
    }

    final normalized = value.trim().toLowerCase();

    for (final entry in _synonyms.entries) {
      if (entry.value.contains(normalized)) return entry.key;
    }

    return VerificationRequestStatus.unknown;
  }
}
