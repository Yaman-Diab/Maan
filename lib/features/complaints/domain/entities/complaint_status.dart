// -------------------------
// Complaint Status
// -------------------------

/// حالة الشكوى بعد نشرها — ثلاث قيم مؤكّدة من endpoints الأدمن الحقيقية
/// (`GET /api/admin/complains?status=under_review` و
/// `PUT /api/admin/complains/:id/status` بخيارَي `in_progress`/`closed`
/// بس المسموحين).
///
/// ⚠️ **الطارئة بلا `underReview`** — بتُنشر فوراً بحالة `inProgress`
/// مباشرة (`published: true` من أول لحظة)، بعكس الفردية والجماعية
/// اللي بتضل `underReview` لحد ما يوافق الموظّف. راجع منطق التصميم
/// الأصلي (`Complaints Screens.dc.html`) — نفس الافتراض.
enum ComplaintStatus {
  underReview('under_review'),
  inProgress('in_progress'),
  closed('closed'),

  /// قيمة ما بنعرفها — بطاقة الشكوى بتعرضها بلا لون دلالي مميّز بدل ما
  /// تفترض حالة.
  unknown('');

  const ComplaintStatus(this.wireValue);

  final String wireValue;

  static ComplaintStatus fromApi(String? value) {
    if (value == null || value.isEmpty) return ComplaintStatus.unknown;

    for (final status in ComplaintStatus.values) {
      if (status.wireValue == value) return status;
    }

    return ComplaintStatus.unknown;
  }
}
