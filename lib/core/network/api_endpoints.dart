// -------------------------
// API Endpoints
// -------------------------

/// مسارات الـ backend كما هي موثّقة بـ`collection.md`.
///
/// ملاحظة: ما في بادئة `v1` — المسارات تحت `/api` مباشرة.
class ApiEndpoints {
  ApiEndpoints._();

  static const String api = '/api';

  // -------------------------
  // Auth
  // -------------------------

  static const String login = '$api/auth/login';
  static const String register = '$api/auth/register';
  static const String logout = '$api/auth/logout';
  static const String refresh = '$api/auth/refresh';

  /// تأكيد رمز التحقق. الجسم بياخد `code` فقط.
  static const String checkCode = '$api/auth/checkCode';

  static const String forgetPassword = '$api/auth/forgetPassword';
  static const String resetPassword = '$api/auth/resetPassword';

  /// إعادة إرسال رسالة التحقق (اصطلاح Laravel).
  static const String emailVerificationNotification =
      '$api/email/verification-notification';

  // -------------------------
  // Profile
  // -------------------------

  /// بيانات المواطن الحالي. بيحتاج توكن — الباك اند بيحدد المستخدم من
  /// الـ `Authorization` header لا من مُعرّف بالمسار.
  static const String profile = '$api/profile';

  /// تحديث الملف الشخصي — **مؤكّد من الباك اند** (مش موجود
  /// بـ`collection.md`، فهذا مصدره الوحيد).
  ///
  /// مسار واحد لكل تعديل، والصورة الشخصية وحدة من حقوله لا endpoint
  /// مستقل. يعني شاشة تعديل بيانات الهوية لما تنبني بتضرب نفس المسار.
  ///
  /// ⚠️ لسه غير مؤكّد: **أسماء الحقول** — راجع
  /// `ProfileRemoteDataSource._avatarField`.
  static const String profileUpdate = '$api/profile/update';

  // -------------------------
  // Verification
  // -------------------------

  /// طلبات التوثيق تبع المستخدم الحالي — الباك اند بيحدده من الـ
  /// `Authorization` header متل [profile]، فما إله وسيط بالمسار.
  ///
  /// هو **الوحيد** اللي بيخلّي شاشة التوثيق تعرف وين المستخدم واقف
  /// (نموذج فاضي / قيد المراجعة / مرفوض / معتمد) وقت ما تُفتح. بلاه
  /// الشاشة ما بتقدر تعرض غير النموذج.
  ///
  /// ⚠️ **شكل الاستجابة غير مؤكّد** — `collection.md` بيسرد المسار
  /// (`GET /api/verification`) بس مثال الاستجابة فيه `{}` فاضي. فـ
  /// `VerificationRequestModel.listFromResponse` بتقرأ الشكلين
  /// المحتملين (قائمة أو كائن مفرد، مغلّفين بـ`data` أو لا) بدل ما
  /// تفترض واحد. نقطة التصحيح الوحيدة لما يتأكّد الشكل الحقيقي.
  static const String verificationIndex = '$api/verification';

  /// تقديم طلب توثيق هوية — `national_id` + صورتين بالضبط (`images[]`).
  /// رسالة الباك اند عند مخالفة العدد: "must contain 2 items" —
  /// يعني قاعدة `size:2` لا `min:2`، فالعدد ثابت لا حد أدنى.
  /// مؤكّد من الباك اند مع مثال استجابة حقيقي.
  static const String verificationStore = '$api/verification/store';

  /// تعديل طلب توثيق **قائم** (لسه `pending`) — تصحيح رقم وطني غلط بلا
  /// ما يعيد رفع الصور. مؤكّد من الباك اند مع مثال استجابة حقيقي.
  ///
  /// ⚠️ **الجسم مؤكّد جزئياً** — `id` (معرّف طلب التوثيق) و`national_id`
  /// بس. تحديث الصور عبر هالمسار **غير مجرَّب**؛ راجع
  /// `VerificationRemoteDataSource.update`.
  static const String verificationUpdate = '$api/verification/update';
}
