// -------------------------
// Display Date Format
// -------------------------

/// القيمة اللي بتنعرض مطرح تاريخ غائب.
const String missingDateValue = '—';

/// تنسيق التاريخ الموحّد بكل التطبيق — أي تاريخ بينعرض للمستخدم بيمرّ
/// من هون، مش بتنسيق مستقل بكل شاشة.
///
/// كانت هاي منطق خاص جوّا `IdentityInfoCard` بميزة profile، وانتقلت
/// لـ`core` لما احتاجتها شاشة التوثيق (بطاقة البيانات الشخصية وتاريخ
/// الإرسال) بنفس الشكل حرفياً — نفس سبب انتقال `AppCard`/`ImageSourceSheet`.
extension DisplayDateFormat on DateTime? {
  /// `12 / 10 / 1998` — يوم/شهر/سنة.
  ///
  /// بأرقام لاتينية بالعربي كمان عن قصد، لا `DateFormat` محلي: باقي
  /// التطبيق (طول الرمز، العمر) بيعرض أرقامه لاتينية، والخلط بين ١٢
  /// و12 بنفس الشاشة أسوأ من الاثنين.
  String get displayDate {
    final date = this;
    if (date == null) return missingDateValue;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day / $month / ${date.year}';
  }
}
