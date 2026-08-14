// -------------------------
// Account Status
// -------------------------

/// حالة حساب المواطن — تحكم ما يُسمح له بعمله.
///
/// ✅ **مؤكّدة بالكامل** — مصدرها enum الباك اند الحقيقي
/// (`App\Enums\AccountStatus`، ثلاث قيم بالضبط: `visitor` · `verified` ·
/// `closed`). لا يوجد حالة "بانتظار التحقق" منفصلة على مستوى الحساب:
/// مستخدم بريده غير مؤكّد بعد بيوصل بـ`account_status: "visitor"` هو
/// هو (تأكّدنا من استجابة حقيقية لـ`GET /api/verification` فيها
/// `"email_verified_at": null` مع `"account_status": "visitor"`) —
/// تأكيد البريد متتبَّع بحقل منفصل (`AuthUser.isEmailVerified`)، مش
/// بحالة حساب مستقلة. لهيك ما في `pendingVerification` هون عمداً.
enum AccountStatus {
  /// بريده مؤكّد بس هويته لسه ما توثّقت — تصفّح فقط.
  visitor('visitor'),

  /// موثّق بالكامل — كل خدمات البلدية متاحة.
  verified('verified'),

  /// حساب مقفول من البلدية — الاسم الحقيقي `closed` عالسلك (لا
  /// `blocked` كما خمّنّا قبل التأكيد).
  closed('closed'),

  /// قيمة ما بنعرفها. بتنعامل كأقل صلاحية عمداً — أأمن من افتراض
  /// إن المستخدم موثّق. حماية من إضافة الباك اند حالة رابعة مستقبلاً.
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

  /// مقفول فيحتاج تدخّل البلدية.
  bool get isClosed => this == AccountStatus.closed;
}
