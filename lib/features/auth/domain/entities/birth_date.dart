// -------------------------
// Birth Date
// -------------------------

import 'package:equatable/equatable.dart';

enum BirthDateError { missing, invalidYear, invalidMonth, invalidDate, tooYoung }

/// تاريخ الميلاد كقيمة لها قواعدها.
///
/// كان هذا المنطق موزّعاً على getters داخل `SignUpController` ومربوطاً
/// بـ`TextEditingController`. صار هون كـ Dart نقي، فصار قابل للاختبار
/// بحالاته الحدية (29 شباط، عمر 16 بالضبط، يوم 31 بشهر 30).
final class BirthDate extends Equatable {
  static const int minimumAge = 16;
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

  /// الشكل اللي بيتوقعه الـ backend: `YYYY-MM-DD`.
  String get formatted {
    final paddedMonth = month.toString().padLeft(2, '0');
    final paddedDay = day.toString().padLeft(2, '0');

    return '$year-$paddedMonth-$paddedDay';
  }

  @override
  List<Object?> get props => [day, month, year];
}
