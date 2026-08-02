import 'package:easy_localization/easy_localization.dart';

import 'password_policy.dart';

class AppValidators {
  // -------------------------
  // Field Limits
  // -------------------------

  /// الحد الأقصى الفعلي لعنوان بريد صالح حسب RFC 5321 — رقم معياري
  /// لا تخمين، وبيطابق `varchar(255)` الافتراضي لأعمدة Laravel.
  static const int emailMaxLength = 254;

  /// bcrypt (مُشفّر Laravel الافتراضي) بيقصّ عند 72 بايت — أي حرف بعدها
  /// بينتجاهل بصمت، وهاد معروف كثغرة (bcrypt truncation) لا مجرد قيد
  /// سعة. 64 هامش آمن تحتها وبعيد عن أي كلمة مرور بشرية حقيقية.
  static const int passwordMaxLength = 64;

  /// أطول اسم حقيقي موثّق ~35 حرف، فـ50 هامش مريح.
  static const int nameMaxLength = 50;

  /// أطول رقم وطني بالمنطقة ~12 خانة.
  static const int nationalIdMaxLength = 12;

  // -------------------------
  // Name Validator
  // -------------------------

  /// حقل اسم مطلوب — بيستخدمه التسجيل وتعديل الهوية.
  ///
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

  /// الرقم الوطني مطلوب. بلا فحص طول أدنى: عدد الخانات بيختلف حسب
  /// الجهة المُصدِرة، والباك اند هو المرجع — فحص محلي متشدّد بيحجب
  /// أرقاماً صحيحة.
  static String? requiredNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'field_required'.tr(namedArgs: {'field': 'national_id'.tr()});
    }

    return null;
  }

  // -------------------------
  // Email Validator
  // -------------------------
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'email_required'.tr();
    }

    final email = value.trim();

    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!regex.hasMatch(email)) {
      return 'email_invalid'.tr();
    }

    return null;
  }

  // -------------------------
  // Password Validators
  // -------------------------

  /// لشاشة الدخول: كلمة المرور موجودة أصلاً بحساب المستخدم، فما إلها
  /// معنى نفرض عليها سياسة القوة الحالية — حساب قديم بكلمة مرور
  /// صحيحة بس ما بتحقق الشروط الجديدة (مثلاً بلا رمز خاص) كان
  /// [passwordValidator] بيمنع صاحبه من تسجيل الدخول إطلاقاً.
  static String? loginPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'password_required'.tr();
    }

    return null;
  }

  /// لشاشات إنشاء/تغيير كلمة المرور، وين فعلاً عم تُنشأ قيمة جديدة
  /// ولازم تحقق السياسة الكاملة.
  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'password_required'.tr();
    }

    final password = value.trim();

    if (!PasswordPolicy.hasMinLength(password)) {
      return 'password_too_short'.tr();
    }

    if (!PasswordPolicy.hasDigit(password)) {
      return 'password_needs_digit'.tr();
    }

    if (!PasswordPolicy.hasUppercase(password)) {
      return 'password_needs_uppercase'.tr();
    }

    if (!PasswordPolicy.hasLowercase(password)) {
      return 'password_needs_lowercase'.tr();
    }

    if (!PasswordPolicy.hasSpecialCharacter(password)) {
      return 'password_needs_special_char'.tr();
    }

    return null;
  }

  static String? confirmPasswordValidator(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'confirm_password_required'.tr();
    }
    if (value != password) {
      return 'passwords_do_not_match'.tr();
    }
    return null;
  }
}
