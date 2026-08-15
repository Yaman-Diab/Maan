// -------------------------
// Complaint Report Reason
// -------------------------

/// سبب الإبلاغ عن شكوى — حقل `type_id` بجسم `POST /api/reports`.
///
/// ⚠️ **الترقيم مخمَّن** — Postman collection عندها مثال وحيد
/// (`type_id: 2` لصورة غير لائقة) بلا قائمة كاملة مرقّمة. رتّبناها 1-6
/// بنفس ترتيب يوزر ستوري #5 (عنيف/غير لائق/مضلّل/مسيء/غير ذي صلة/أخرى)
/// — يطابق المثال الوحيد المؤكّد (`inappropriate` = 2). نقطة التصحيح
/// الوحيدة لو تأكّد ترقيم مختلف: هالملف بس.
enum ComplaintReportReason {
  violent(1),
  inappropriate(2),
  misleading(3),
  abusive(4),
  irrelevant(5),
  other(6);

  const ComplaintReportReason(this.typeId);

  final int typeId;
}
