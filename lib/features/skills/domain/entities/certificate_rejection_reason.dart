// -------------------------
// Certificate Rejection Reason
// -------------------------

/// سبب رفض شهادة إثبات — ثمانية قيم، مؤكّدة من `App\Enums\CertificateRejectionReason`
/// الحقيقي. **منفصل تماماً** عن سبب رفض طلب توثيق الهوية
/// (`features/verification/`) — عقد مختلف بالكامل رغم تشابه الفكرة.
enum CertificateRejectionReason {
  fakeDocument('fake_document'),
  expiredDocument('expired_document'),
  invalidDocument('invalid_document'),
  blurryImage('blurry_image'),
  nameMismatch('name_mismatch'),
  issuerUnverifiable('issuer_unverifiable'),
  missingInformation('missing_information'),
  other('other');

  const CertificateRejectionReason(this.wireValue);

  final String wireValue;

  static CertificateRejectionReason fromApi(String? value) {
    for (final reason in CertificateRejectionReason.values) {
      if (reason.wireValue == value) return reason;
    }

    return CertificateRejectionReason.other;
  }
}
