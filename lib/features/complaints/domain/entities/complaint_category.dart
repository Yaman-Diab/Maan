// -------------------------
// Complaint Category
// -------------------------

/// تصنيف الشكوى — ستة تصنيفات ثابتة، `id` مؤكّد من Postman collection
/// حقيقي (`category_id` بجسم `POST /api/complains`). لا endpoint لجلبها
/// من الباك اند — ثابتة بالكود بالتصميم.
enum ComplaintCategory {
  roads(1),
  waste(2),
  lighting(3),
  water(4),
  publicServices(5),
  other(6);

  const ComplaintCategory(this.id);

  final int id;

  static ComplaintCategory? fromApi(int? id) {
    for (final category in ComplaintCategory.values) {
      if (category.id == id) return category;
    }

    return null;
  }
}
