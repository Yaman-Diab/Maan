import 'package:easy_localization/easy_localization.dart';
import 'package:maan/core/design_system/app_strings.dart';

class AppValidators {
  // -------------------------
  // Email Validator
  // -------------------------
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.emailRequired.tr();
    }

    final email = value.trim();

    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!regex.hasMatch(email)) {
      return AppStrings.emailInvalid.tr();
    }

    return null;
  }

  // -------------------------
  // Password Validator
  // -------------------------
  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired.tr();
    }

    final password = value.trim();

    // At least 8 characters
    if (password.length < 8) {
      return AppStrings.passwordTooShort.tr();
    }

    // At least 1 number
    if (!RegExp(r'\d').hasMatch(password)) {
      return AppStrings.passwordNeedsDigit.tr();
    }

    // Uppercase
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return AppStrings.passwordNeedsUppercase.tr();
    }

    // Lowercase
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return AppStrings.passwordNeedsLowercase.tr();
    }

    // Special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]=+]').hasMatch(password)) {
      return AppStrings.passwordNeedsSpecialChar.tr();
    }

    return null;
  }

  static String? confirmPasswordValidator(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordRequired.tr();
    }
    if (value != password) {
      return AppStrings.passwordsDoNotMatch.tr();
    }
    return null;
  }
}
