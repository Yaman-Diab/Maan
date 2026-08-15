// -------------------------
// Complaint Sort
// -------------------------

/// ترتيب قائمة الشكاوى المنشورة — مؤكّد من وسيط `sort` بـ
/// `GET /api/complains/complains` (`priority` حسب الأصوات ووزن
/// التصنيف، `newest`، `oldest`).
enum ComplaintSort {
  priority('priority'),
  newest('newest'),
  oldest('oldest');

  const ComplaintSort(this.wireValue);

  final String wireValue;
}
