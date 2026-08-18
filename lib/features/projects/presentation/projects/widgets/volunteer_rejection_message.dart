// -------------------------
// Volunteer Rejection Message
// -------------------------

import 'package:easy_localization/easy_localization.dart';

/// ترجمة سبب رفض طلب التطوع لرسالة عربية مفهومة.
///
/// ⚠️ **مطابقة نصّية على رسالة الباك اند — هشّة عمداً، وبديلها أسوأ**:
/// الباك اند بيرجّع سبع حالات رفض مختلفة كلها `422`/`409` برسالة
/// إنجليزية، **بلا حقل `code` ثابت** نقدر نطابق عليه (شكل الخطأ
/// `{"status":0,"message":"...","errors":{"general":[...]}}` بس).
/// البدائل كانت:
/// * عرض الرسالة الخام → إنجليزي لمستخدم عربي (نفس باگ `409` الموثّق
///   بالشكاوى).
/// * رسالة عامة وحدة → بتضيّع أهم معلومة: **ليش** انرفض الطلب
///   («فترة التطوع خلصت» مختلفة جذرياً عن «مهاراتك ما بتطابق»).
///
/// فالمطابقة النصّية أقل الخيارات سوءاً. بتفشل بهدوء (بترجّع الرسالة
/// الأصلية) لو غيّر الباك اند صياغته — ما بتنهار ولا بتخفي الخطأ.
/// **لو انضاف حقل `code` للباك اند، هالملف بينشال ويتبدّل بمطابقة
/// عليه.**
class VolunteerRejectionMessage {
  VolunteerRejectionMessage._();

  /// أجزاء مميّزة من كل رسالة (لا الرسالة كاملة) — أقل حساسية لتغييرات
  /// صياغة صغيرة زي علامة ترقيم أو حرف كبير.
  ///
  /// ⚠️ **دوال ترجمة لا أسماء مفاتيح** — ماسح `localization_test`
  /// بيتطلّب المفتاح يكون **نصاً حرفياً قبل `.tr()` مباشرة** بنفس
  /// السطر. خريطة `String → String` بأسماء مفاتيح كانت بتخلّي المفاتيح
  /// تنحسب «غير مستخدمة» ويوقّع الاختبار. نفس نمط `ProfileContent._count`.
  static final Map<String, String Function()> _patterns = {
    'does not accept volunteers': () => 'volunteer_error_not_accepting'.tr(),
    'not currently open': () => 'volunteer_error_closed'.tr(),
    'has not started yet': () => 'volunteer_error_not_started'.tr(),
    'period has ended': () => 'volunteer_error_ended'.tr(),
    'already applied': () => 'volunteer_error_already_applied'.tr(),
    'not configured': () => 'volunteer_error_not_configured'.tr(),
    'no suitable volunteer slot': () => 'volunteer_error_no_slot'.tr(),
    'project not found': () => 'volunteer_error_project_not_found'.tr(),
  };

  /// بترجّع رسالة مترجَمة لو تعرّفنا على السبب، وإلا [fallback] كما هي.
  static String resolve(String fallback) {
    final normalized = fallback.toLowerCase();

    for (final entry in _patterns.entries) {
      if (normalized.contains(entry.key)) return entry.value();
    }

    return fallback;
  }
}
