class AppStrings {
  // -------------------------
  // Auth Fields
  // -------------------------
  static const String email = "email";
  static const String enterEmail = "enter_email";
  static const String password = "password";
  static const String enterPassword = "enter_password";
  static const String confirmPassword = "confirm_password";
  static const String enterConfirmPassword = "enter_confirm_password";

  // -------------------------
  // Validation Messages (USED IN VALIDATORS ONLY)
  // -------------------------
  static const String emailRequired = 'email_required';
  static const String emailInvalid = 'email_invalid';

  static const String passwordRequired = 'password_required';
  static const String passwordTooShort = 'password_too_short';
  static const String passwordNeedsUppercase = 'password_needs_uppercase';
  static const String passwordNeedsLowercase = 'password_needs_lowercase';
  static const String passwordNeedsDigit = 'password_needs_digit';
  static const String passwordNeedsSpecialChar = 'password_needs_special_char';
  static const String confirmPasswordRequired = 'confirm_password_required';
  static const String passwordsDoNotMatch = 'passwords_do_not_match';
}