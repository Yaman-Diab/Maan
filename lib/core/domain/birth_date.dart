// -------------------------
// Birth Date
// -------------------------

import 'package:equatable/equatable.dart';

enum BirthDateError { missing, invalidYear, invalidMonth, invalidDate, tooYoung }

/// تاريخ الميلاد كقيمة لها قواعدها.
///
/// كان هذا المنطق موزّعاً على getters داخل `SignUpController` ومربوطاً
/// بـ`TextEditingController`. صار هون كـ Dart نقي، فصار قابل للاختبار
/// بحالاته الحدية (29 شباط، عمر 14 بالضبط، يوم 31 بشهر 30).
final class BirthDate extends Equatable {
  /// سنّ استلام الهوية الشخصية — مؤكَّد من صاحب المشروع، لا افتراض.
  /// كان الكود القديم بـ`SignUpController` مبني على 16 خطأً؛ التوثيق
  /// (`User Story Documentation.md`) نصّ على 14 من البداية.
  static const int minimumAge = 14;
  static const int minimumYear = 1900;

  final int day;
  final int month;
  final int year;

  const BirthDate({required this.day, required this.month, required this.year});

  /// أحدث سنة ميلاد مقبولة حسب الحد الأدنى للعمر.
  static int maxAllowedYear([DateTime? now]) {
    return (now ?? DateTime.now()).year - minimumAge;
  }

  /// عدد أيام الشهر — بيتعامل مع السنة الكبيسة تلقائياً.
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // -------------------------
  // قيم عجلات الاختيار
  // -------------------------
  //
  // دوال نقية على الأجزاء الثلاثة، مش getters على حالة شاشة — لأن
  // شاشتين بتستخدموها (التسجيل وتعديل الهوية) وكانت منسوخة بالاثنتين.
  // مكانها هون لأنها قواعد التاريخ نفسه لا قواعد عرض.

  /// أقصى يوم متاح للشهر/السنة المختارين، مع قيم افتراضية آمنة لو
  /// المستخدم لسه ما اختار.
  static int maxSelectableDay({int? month, int? year}) {
    return daysInMonth(
      year ?? maxAllowedYear(),
      month ?? DateTime.now().month,
    );
  }

  /// اليوم اللي المفروض تفتح عليه العجلة — مقصوص لحدود الشهر.
  static int initialDay({int? day, int? month, int? year}) {
    final maxDay = maxSelectableDay(month: month, year: year);
    final selected = day ?? 1;

    if (selected < 1) return 1;
    if (selected > maxDay) return maxDay;

    return selected;
  }

  static int initialMonth([int? month]) {
    final selected = month ?? DateTime.now().month;

    if (selected < 1 || selected > 12) return DateTime.now().month;

    return selected;
  }

  static int initialYear([int? year]) {
    final maxYear = maxAllowedYear();
    final selected = year ?? maxYear;

    if (selected < minimumYear || selected > maxYear) return maxYear;

    return selected;
  }

  /// السنوات المتاحة، الأحدث أولاً.
  static List<int> selectableYears() {
    final maxYear = maxAllowedYear();

    return List.generate(
      maxYear - minimumYear + 1,
      (index) => maxYear - index,
    );
  }

  /// بيقصّ اليوم المختار لو صار خارج حدود الشهر/السنة الجديدة
  /// (مثلاً 31 ثم شهر فيه 30 يوم). بيرجّع `null` لو ما في يوم مختار.
  static int? clampDay({required int? day, int? month, int? year}) {
    if (day == null) return null;

    final maxDay = maxSelectableDay(month: month, year: year);

    return day > maxDay ? maxDay : day;
  }

  /// بيتحقق من الأجزاء قبل ما تتكوّن قيمة صالحة.
  ///
  /// بيرجّع `null` لو التاريخ سليم. [now] بتنحقن بالاختبارات حتى ما
  /// يصير التحقق معتمد على تاريخ اليوم الحقيقي.
  static BirthDateError? validateParts({
    int? day,
    int? month,
    int? year,
    DateTime? now,
  }) {
    if (day == null || month == null || year == null) {
      return BirthDateError.missing;
    }

    final today = now ?? DateTime.now();

    if (year < minimumYear || year > maxAllowedYear(today)) {
      return BirthDateError.invalidYear;
    }

    if (month < 1 || month > 12) {
      return BirthDateError.invalidMonth;
    }

    // DateTime بتلفّ التواريخ غير الموجودة (31 نيسان → 1 أيار)،
    // فبنقارن بالأجزاء الأصلية لنكشفها.
    final date = DateTime(year, month, day);

    if (date.year != year || date.month != month || date.day != day) {
      return BirthDateError.invalidDate;
    }

    final minimumAllowedDate = DateTime(
      today.year - minimumAge,
      today.month,
      today.day,
    );

    if (date.isAfter(minimumAllowedDate)) {
      return BirthDateError.tooYoung;
    }

    return null;
  }

  /// الشكل اللي بيتوقعه الـ backend: `YYYY/M/D` بشرطة مائلة وبلا تصفير،
  /// مطابق للمثال الموثّق (`2003/2/1`).
  String get apiFormat => '$year/$month/$day';

  @override
  List<Object?> get props => [day, month, year];
}
