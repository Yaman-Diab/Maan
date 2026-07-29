import '../../domain/entities/birth_date.dart';

/// ترجمة خطأ الـ domain لرسالة عرض.
///
/// الـ domain بيرجّع [BirthDateError] بلا نصوص، فبيضل قابل للاختبار
/// ومستقل عن لغة الواجهة؛ الربط بالنص بيصير هون.
extension BirthDateErrorMessage on BirthDateError {
  String get message => switch (this) {
    BirthDateError.missing => 'Birthday is required',
    BirthDateError.invalidYear => 'Please select a valid birth year',
    BirthDateError.invalidMonth => 'Please select a valid birth month',
    BirthDateError.invalidDate => 'Please select a valid birth date',
    BirthDateError.tooYoung =>
      'You must be at least ${BirthDate.minimumAge} years old',
  };
}
