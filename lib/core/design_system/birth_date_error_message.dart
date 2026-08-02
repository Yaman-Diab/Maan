import 'package:easy_localization/easy_localization.dart';

import 'package:maan/core/domain/birth_date.dart';

/// ترجمة خطأ الـ domain لرسالة عرض.
///
/// الـ domain بيرجّع [BirthDateError] بلا نصوص، فبيضل قابل للاختبار
/// ومستقل عن لغة الواجهة؛ الربط بالنص بيصير هون عبر easy_localization.
extension BirthDateErrorMessage on BirthDateError {
  String get message => switch (this) {
    BirthDateError.missing => 'birthday_required'.tr(),
    BirthDateError.invalidYear => 'birthday_invalid_year'.tr(),
    BirthDateError.invalidMonth => 'birthday_invalid_month'.tr(),
    BirthDateError.invalidDate => 'birthday_invalid_date'.tr(),
    BirthDateError.tooYoung => 'birthday_too_young'.tr(
      namedArgs: {'age': '${BirthDate.minimumAge}'},
    ),
  };
}
