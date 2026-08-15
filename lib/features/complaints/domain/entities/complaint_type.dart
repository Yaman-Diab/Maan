// -------------------------
// Complaint Type
// -------------------------

/// نوع الشكوى — مؤكّد من Postman collection حقيقي (حقل `type` بجسم
/// `POST /api/complains`، enum ثلاثي حرفي).
enum ComplaintType {
  individual('individual'),
  collective('collective'),
  emergency('emergency');

  const ComplaintType(this.wireValue);

  final String wireValue;

  static ComplaintType? fromApi(String? value) {
    for (final type in ComplaintType.values) {
      if (type.wireValue == value) return type;
    }

    return null;
  }
}
