// -------------------------
// Account Status
// -------------------------

/// حالة حساب المواطن — تحكم ما يُسمح له بعمله.
///
/// حسب `PROJECT_CONTEXT.md` المواطن بيمرّ برحلة:
/// تسجيل → تحقق بريد → **Visitor** → توثيق هوية → **Verified Citizen**،
/// وبينحظر لو انتهت مهلة التوثيق أو استنفد المحاولات الثلاث.
///
/// ⚠️ **`verified` هي القيمة الوحيدة المؤكّدة** من استجابة حقيقية
/// بـ`collection.md` (`"account_status":"verified"` بـ`/api/profile`).
/// باقي القيم مشتقّة من تسمية `PROJECT_CONTEXT` ولسه بدها تأكيد من
/// الباك اند — ولهيك [fromApi] بترجّع [unknown] بدل ما ترمي.
enum AccountStatus {
  /// انتهى التسجيل وما تأكّد البريد بعد.
  pendingVerification('pending_verification'),

  /// بريده مؤكّد بس هويته لسه ما توثّقت — تصفّح فقط.
  visitor('visitor'),

  /// موثّق بالكامل — كل خدمات البلدية متاحة.
  verified('verified'),

  /// محظور: انتهت مهلة التوثيق أو استُنفدت المحاولات.
  blocked('blocked'),

  /// قيمة ما بنعرفها. بتنعامل كأقل صلاحية عمداً — أأمن من افتراض
  /// إن المستخدم موثّق.
  unknown('');

  const AccountStatus(this.wireValue);

  /// القيمة كما بيرسلها الـ backend بحقل `account_status`.
  final String wireValue;

  static AccountStatus fromApi(String? value) {
    if (value == null || value.isEmpty) return AccountStatus.unknown;

    for (final status in AccountStatus.values) {
      if (status.wireValue == value) return status;
    }

    return AccountStatus.unknown;
  }

  /// الصلاحية الوحيدة اللي بتفتح خدمات البلدية.
  ///
  /// `PROJECT_CONTEXT` بينص إن الشكاوى والتصويت والتبرع والتطوع كلها
  /// ممنوعة قبل التوثيق العام.
  bool get canUseMunicipalityServices => this == AccountStatus.verified;

  /// محظور فيحتاج تدخّل البلدية.
  bool get isBlocked => this == AccountStatus.blocked;
}
