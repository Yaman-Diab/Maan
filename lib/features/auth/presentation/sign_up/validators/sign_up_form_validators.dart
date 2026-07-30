import 'package:easy_localization/easy_localization.dart';

class SignUpFormValidators {
  const SignUpFormValidators._();

  /// [fieldName] بيوصل مترجم أصلاً من موقع الاستدعاء (`'first_name'.tr()`)
  /// وبينحط بالرسالة عبر `namedArgs`، فترتيب الكلمة بيتبع قواعد كل لغة
  /// بدل ما ينبني بالتسلسل الإنجليزي.
  static String? requiredName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'field_required'.tr(namedArgs: {'field': fieldName});
    }

    if (value.trim().length < 2) {
      return 'field_too_short'.tr(namedArgs: {'field': fieldName});
    }

    return null;
  }

  /// حقول التاريخ بتتحقق كقيمة وحدة داخل `SignUpCubit` عبر
  /// `BirthDate.validateParts`، فبنخلّي هذا فاضي حتى ما تظهر ثلاث
  /// رسائل مكررة تحت الحقول.
  static String? dateField(String? value) => null;
}
