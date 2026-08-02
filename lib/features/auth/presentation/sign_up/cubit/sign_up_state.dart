// -------------------------
// Sign Up State
// -------------------------

import 'package:equatable/equatable.dart';

import 'package:maan/core/domain/birth_date.dart';
import '../../../domain/entities/password_checks.dart';

enum SignUpStatus { initial, submitting, success, failure }

final class SignUpState extends Equatable {
  final SignUpStatus status;

  final String firstName;
  final String lastName;

  /// الرقم الوطني — مطلوب من الـ backend عند التسجيل، لكن لسه ما إله
  /// حقل بالواجهة، فبيوصل فاضي وبيرجع خطأ تحقق من السيرفر.
  final String nationalId;

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
    this.nationalId = '',
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
    // nationalId مقصود إنه مش شرط هون: الـ backend بيطلبه، بس ما في
    // حقل إله بالواجهة بعد. راجع ملاحظة الفجوة بـ CLAUDE.md.
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

  int get maxDayForSelectedMonthYear =>
      BirthDate.maxSelectableDay(month: month, year: year);

  int get initialDay =>
      BirthDate.initialDay(day: day, month: month, year: year);

  int get initialMonth => BirthDate.initialMonth(month);

  int get initialYear => BirthDate.initialYear(year);

  List<int> get yearValues => BirthDate.selectableYears();

  SignUpState copyWith({
    SignUpStatus? status,
    String? firstName,
    String? lastName,
    String? nationalId,
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
      nationalId: nationalId ?? this.nationalId,
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
    nationalId,
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
