// -------------------------
// Verification Request Status
// -------------------------

/// حالة **طلب التوثيق نفسه** — غير `AccountStatus` (حالة الحساب العامة
/// بـ`core/session/`). الطلب بيبدأ `pending`، والباك اند لاحقاً بيغيّر
/// `AccountStatus` تبع المستخدم (verified/blocked) بعد المراجعة.
///
/// ⚠️ **`pending` هي القيمة الوحيدة المؤكّدة** — من استجابة
/// `POST /api/verification/store` الحقيقية. قيم الموافقة/الرفض متوقّعة
/// منطقياً (أي طلب مراجعة لازم يخلص لحالة نهائية) بس أسماءها بالسلك لسه
/// ما تأكّدت، فـ[fromApi] بترجّع [unknown] بدل ما ترمي أو تخمّن.
enum VerificationRequestStatus {
  pending('pending'),
  unknown('');

  const VerificationRequestStatus(this.wireValue);

  final String wireValue;

  static VerificationRequestStatus fromApi(String? value) {
    if (value == null || value.isEmpty) {
      return VerificationRequestStatus.unknown;
    }

    for (final status in VerificationRequestStatus.values) {
      if (status.wireValue == value) return status;
    }

    return VerificationRequestStatus.unknown;
  }
}
