// -------------------------
// Edit Identity State
// -------------------------

import 'package:equatable/equatable.dart';

import 'package:maan/core/domain/birth_date.dart';

enum EditIdentityStatus { initial, submitting, success, failure }

/// حالة شاشة تعديل بيانات الهوية.
///
/// [isLocked] بتتحدّد مرة وحدة وقت بناء الـ Cubit من حالة الحساب —
/// الشاشة أصلاً ما بتنفتح للموثّق (`ProfileContent._identityAction`)،
/// بس منحطّها هون كحارس دفاعي ثاني لو تغيّرت الحالة والشاشة مفتوحة.
final class EditIdentityState extends Equatable {
  final EditIdentityStatus status;

  final String firstName;
  final String lastName;
  final String nationalId;

  /// تاريخ الميلاد بأجزائه — نفس نمط `SignUpState`: الحالة مصدر
  /// الحقيقة، وحقول الواجهة read-only بتتعبّى من الـ pickers.
  final int? day;
  final int? month;
  final int? year;

  final bool isLocked;
  final bool hasTriedSubmit;
  final BirthDateError? birthDateError;
  final String? errorMessage;

  const EditIdentityState({
    this.status = EditIdentityStatus.initial,
    this.firstName = '',
    this.lastName = '',
    this.nationalId = '',
    this.day,
    this.month,
    this.year,
    this.isLocked = false,
    this.hasTriedSubmit = false,
    this.birthDateError,
    this.errorMessage,
  });

  bool get isSubmitting => status == EditIdentityStatus.submitting;

  bool get hasBirthDateError => birthDateError != null;

  /// ⚠️ **`nationalId` مش شرط هون عن قصد** — من يوم ما صارت شاشة
  /// التوثيق مالكته الوحيدة، المستخدم غير الموثّق ما عنده رقم وطني
  /// أصلاً (`null`). لو ضل شرطاً، هو بالضبط اللي **ما بيقدر** يعدّل
  /// اسمه أو تاريخ ميلاده — الزر بيضل مقفولاً للأبد.
  ///
  /// القيمة بتضل محمولة بالحالة وبتنبعت كما هي مع الطلب، لأن
  /// `POST /api/profile/update` بياخد الحقل ضمن جسم واحد؛ إسقاطه من
  /// الإرسال خطر (ممكن الباك اند يقرأ غيابه كـ«امسحه» متل حقل الصورة
  /// الفاضي — راجع `ProfileRemoteDataSource.removeAvatar`).
  bool get canSubmit {
    final areFieldsFilled =
        firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        day != null &&
        month != null &&
        year != null;

    return areFieldsFilled && !isLocked && !isSubmitting;
  }

  // -------------------------
  // Picker Values — نفس منطق SignUpState بالضبط.
  // -------------------------

  int get maxDayForSelectedMonthYear =>
      BirthDate.maxSelectableDay(month: month, year: year);

  int get initialDay =>
      BirthDate.initialDay(day: day, month: month, year: year);

  int get initialMonth => BirthDate.initialMonth(month);

  int get initialYear => BirthDate.initialYear(year);

  List<int> get yearValues => BirthDate.selectableYears();

  EditIdentityState copyWith({
    EditIdentityStatus? status,
    String? firstName,
    String? lastName,
    String? nationalId,
    int? day,
    int? month,
    int? year,
    bool? hasTriedSubmit,
    BirthDateError? birthDateError,
    String? errorMessage,
  }) {
    return EditIdentityState(
      status: status ?? this.status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nationalId: nationalId ?? this.nationalId,
      day: day ?? this.day,
      month: month ?? this.month,
      year: year ?? this.year,
      // ثابتة طول عمر الشاشة — راجع تعليق [isLocked] فوق.
      isLocked: isLocked,
      hasTriedSubmit: hasTriedSubmit ?? this.hasTriedSubmit,
      // ما بتُورَّث: كل حالة بتصرّح بخطئها، فما بيعلق خطأ قديم.
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
    day,
    month,
    year,
    isLocked,
    hasTriedSubmit,
    birthDateError,
    errorMessage,
  ];
}
