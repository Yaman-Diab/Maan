import 'package:easy_localization/easy_localization.dart';

class AppValidators {
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
  // Password Validator
  // -------------------------
  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'password_required'.tr();
    }

    final password = value.trim();

    // At least 8 characters
    if (password.length < 8) {
      return 'password_too_short'.tr();
    }

    // At least 1 number
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'password_needs_digit'.tr();
    }

    // Uppercase
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'password_needs_uppercase'.tr();
    }

    // Lowercase
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'password_needs_lowercase'.tr();
    }

    // Special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]=+]').hasMatch(password)) {
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
