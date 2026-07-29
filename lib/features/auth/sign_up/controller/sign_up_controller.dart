import 'package:flutter/material.dart';

import '../models/sign_up_payload.dart';

class SignUpController extends ChangeNotifier {
  SignUpController() {
    _addInputListeners();
  }

  static const int minimumAge = 16;
  static const int minimumYear = 1900;

  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isSubmitting = false;
  bool isTermsAccepted = false;
  bool hasTriedSubmit = false;

  String? birthdayError;

  bool get canSubmit => _isFormReady && !isSubmitting;

  bool get hasBirthdayError => birthdayError != null;

  int get maxAllowedBirthYear {
    final now = DateTime.now();
    return now.year - minimumAge;
  }

  int get selectedYearForDays {
    return int.tryParse(yearController.text) ?? maxAllowedBirthYear;
  }

  int get selectedMonthForDays {
    return int.tryParse(monthController.text) ?? DateTime.now().month;
  }

  int get maxDayForSelectedMonthYear {
    final year = selectedYearForDays;
    final month = selectedMonthForDays;

    return DateTime(year, month + 1, 0).day;
  }

  int get initialDay {
    final selectedDay = int.tryParse(dayController.text) ?? 1;

    if (selectedDay < 1) return 1;
    if (selectedDay > maxDayForSelectedMonthYear) {
      return maxDayForSelectedMonthYear;
    }

    return selectedDay;
  }

  int get initialMonth {
    final selectedMonth = int.tryParse(monthController.text) ?? DateTime.now().month;

    if (selectedMonth < 1 || selectedMonth > 12) return DateTime.now().month;

    return selectedMonth;
  }

  int get initialYear {
    final selectedYear = int.tryParse(yearController.text) ?? maxAllowedBirthYear;

    if (selectedYear < minimumYear || selectedYear > maxAllowedBirthYear) {
      return maxAllowedBirthYear;
    }

    return selectedYear;
  }

  List<int> get yearValues {
    final yearsCount = maxAllowedBirthYear - minimumYear + 1;

    return List.generate(
      yearsCount,
      (index) => maxAllowedBirthYear - index,
    );
  }

  bool get _isFormReady {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final day = dayController.text.trim();
    final month = monthController.text.trim();
    final year = yearController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    final areFieldsFilled = firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        day.isNotEmpty &&
        month.isNotEmpty &&
        year.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty;

    return areFieldsFilled && isTermsAccepted;
  }

  SignUpPayload get payload {
    return SignUpPayload(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      birthday: '${yearController.text}-${monthController.text}-${dayController.text}',
      email: emailController.text.trim(),
      password: passwordController.text,
    );
  }

  void setTermsAccepted(bool value) {
    if (isTermsAccepted == value) return;

    isTermsAccepted = value;
    notifyListeners();
  }

  void setDay(int day) {
    dayController.text = day.toString().padLeft(2, '0');
    _clearBirthdayError();
    notifyListeners();
  }

  void setMonth(int month) {
    monthController.text = month.toString().padLeft(2, '0');
    _normalizeDayIfNeeded();
    _clearBirthdayError();
    notifyListeners();
  }

  void setYear(int year) {
    yearController.text = year.toString();
    _normalizeDayIfNeeded();
    _clearBirthdayError();
    notifyListeners();
  }

  Future<void> submit({
    required Future<void> Function(SignUpPayload payload) onSubmit,
  }) async {
    if (!canSubmit || isSubmitting) return;

    hasTriedSubmit = true;
    birthdayError = _birthdayValidationMessage();

    final isFormValid = formKey.currentState?.validate() ?? false;

    notifyListeners();

    if (!isFormValid || birthdayError != null) return;

    isSubmitting = true;
    notifyListeners();

    try {
      await onSubmit(payload);
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void _addInputListeners() {
    firstNameController.addListener(_handleInputChanged);
    lastNameController.addListener(_handleInputChanged);
    dayController.addListener(_handleInputChanged);
    monthController.addListener(_handleInputChanged);
    yearController.addListener(_handleInputChanged);
    emailController.addListener(_handleInputChanged);
    passwordController.addListener(_handleInputChanged);
    confirmPasswordController.addListener(_handleInputChanged);
  }

  void _removeInputListeners() {
    firstNameController.removeListener(_handleInputChanged);
    lastNameController.removeListener(_handleInputChanged);
    dayController.removeListener(_handleInputChanged);
    monthController.removeListener(_handleInputChanged);
    yearController.removeListener(_handleInputChanged);
    emailController.removeListener(_handleInputChanged);
    passwordController.removeListener(_handleInputChanged);
    confirmPasswordController.removeListener(_handleInputChanged);
  }

  void _handleInputChanged() {
    notifyListeners();
  }

  String? _birthdayValidationMessage() {
    final day = int.tryParse(dayController.text);
    final month = int.tryParse(monthController.text);
    final year = int.tryParse(yearController.text);

    if (day == null || month == null || year == null) {
      return 'Birthday is required';
    }

    if (year < minimumYear || year > maxAllowedBirthYear) {
      return 'Please select a valid birth year';
    }

    if (month < 1 || month > 12) {
      return 'Please select a valid birth month';
    }

    final selectedDate = DateTime(year, month, day);

    final isRealDate = selectedDate.year == year &&
        selectedDate.month == month &&
        selectedDate.day == day;

    if (!isRealDate) {
      return 'Please select a valid birth date';
    }

    final now = DateTime.now();

    final minimumAllowedDate = DateTime(
      now.year - minimumAge,
      now.month,
      now.day,
    );

    if (selectedDate.isAfter(minimumAllowedDate)) {
      return 'You must be at least $minimumAge years old';
    }

    return null;
  }

  void _clearBirthdayError() {
    if (birthdayError == null) return;

    birthdayError = null;
  }

  void _normalizeDayIfNeeded() {
    final selectedDay = int.tryParse(dayController.text);

    if (selectedDay == null) return;

    final maxDay = maxDayForSelectedMonthYear;

    if (selectedDay > maxDay) {
      dayController.text = maxDay.toString().padLeft(2, '0');
    }
  }

  @override
  void dispose() {
    _removeInputListeners();

    firstNameController.dispose();
    lastNameController.dispose();
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }
}
