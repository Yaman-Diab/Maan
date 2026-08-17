// -------------------------
// Certificate Status
// -------------------------

/// حالة شهادة الإثبات — ثلاث قيم: `pending`/`rejected` مؤكّدتان حرفياً
/// من فلتر `POST /api/certificate/adminIndex` الحقيقي، و`approved`
/// مؤكّدة ضمناً من وجود `GET /api/certificate/approve/{id}`.
enum CertificateStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),

  /// قيمة ما بنعرفها — بتنعامل بحياد بدل ما تفترض حالة.
  unknown('');

  const CertificateStatus(this.wireValue);

  final String wireValue;

  static CertificateStatus fromApi(String? value) {
    if (value == null || value.isEmpty) return CertificateStatus.unknown;

    for (final status in CertificateStatus.values) {
      if (status.wireValue == value) return status;
    }

    return CertificateStatus.unknown;
  }
}
