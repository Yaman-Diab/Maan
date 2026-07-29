// -------------------------
// Sign Up State
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../domain/entities/birth_date.dart';
import '../../../domain/entities/password_checks.dart';

enum SignUpStatus { initial, submitting, success, failure }

final class SignUpState extends Equatable {
  final SignUpStatus status;

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;

  /// تاريخ الميلاد بأجزائه — الحالة هي مصدر الحقيقة، والحقول الثلاثة
  /// بالواجهة للعرض فقط لأنها read-only وبتتعبّى من الـ pickers.
  final int? day;
  final int? month;
  final int? year;

  final bool isTermsAccepted;
  final bool hasTriedSubmit;
  final BirthDateError? birthDateError;
  final String? errorMessage;

  const SignUpState({
    this.status = SignUpStatus.initial,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.day,
    this.month,
    this.year,
    this.isTermsAccepted = false,
    this.hasTriedSubmit = false,
    this.birthDateError,
    this.errorMessage,
  });

  bool get isSubmitting => status == SignUpStatus.submitting;

  bool get hasBirthDateError => birthDateError != null;

  bool get canSubmit {
    final areFieldsFilled =
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        day != null &&
        month != null &&
        year != null &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty;

    return areFieldsFilled && isTermsAccepted && !isSubmitting;
  }

  PasswordChecks get passwordChecks => PasswordChecks.fromPassword(password);

  // -------------------------
  // Picker Values
  // -------------------------

  int get maxDayForSelectedMonthYear {
    return BirthDate.daysInMonth(
      year ?? BirthDate.maxAllowedYear(),
      month ?? DateTime.now().month,
    );
  }

  int get initialDay {
    final selected = day ?? 1;

    if (selected < 1) return 1;
    if (selected > maxDayForSelectedMonthYear) {
      return maxDayForSelectedMonthYear;
    }

    return selected;
  }

  int get initialMonth {
    final selected = month ?? DateTime.now().month;

    if (selected < 1 || selected > 12) return DateTime.now().month;

    return selected;
  }

  int get initialYear {
    final maxYear = BirthDate.maxAllowedYear();
    final selected = year ?? maxYear;

    if (selected < BirthDate.minimumYear || selected > maxYear) {
      return maxYear;
    }

    return selected;
  }

  List<int> get yearValues {
    final maxYear = BirthDate.maxAllowedYear();

    return List.generate(
      maxYear - BirthDate.minimumYear + 1,
      (index) => maxYear - index,
    );
  }

  SignUpState copyWith({
    SignUpStatus? status,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? confirmPassword,
    int? day,
    int? month,
    int? year,
    bool? isTermsAccepted,
    bool? hasTriedSubmit,
    BirthDateError? birthDateError,
    String? errorMessage,
  }) {
    return SignUpState(
      status: status ?? this.status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      day: day ?? this.day,
      month: month ?? this.month,
      year: year ?? this.year,
      isTermsAccepted: isTermsAccepted ?? this.isTermsAccepted,
      hasTriedSubmit: hasTriedSubmit ?? this.hasTriedSubmit,
      // الخطأان ما بينورّثوا: كل حالة بتصرّح فيهم لو بدها إياهم، فما
      // بتعلق رسالة قديمة على حالة جديدة.
      birthDateError: birthDateError,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    firstName,
    lastName,
    email,
    password,
    confirmPassword,
    day,
    month,
    year,
    isTermsAccepted,
    hasTriedSubmit,
    birthDateError,
    errorMessage,
  ];
}
