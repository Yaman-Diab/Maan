class SignUpFormValidators {
  const SignUpFormValidators._();

  static String? requiredName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < 2) {
      return '$fieldName is too short';
    }

    return null;
  }

  /// Date fields are validated as one birthday value inside SignUpController.
  /// We keep this validator empty so the three date fields do not show
  /// duplicated messages.
  static String? dateField(String? value) => null;
}
