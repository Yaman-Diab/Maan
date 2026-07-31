import 'package:flutter_test/flutter_test.dart';
import 'package:maan/features/auth/domain/entities/birth_date.dart';

/// تاريخ ثابت حتى ما يعتمد التحقق على يوم تشغيل الاختبار.
final _now = DateTime(2026, 7, 29);

BirthDateError? _validate({int? day, int? month, int? year}) {
  return BirthDate.validateParts(
    day: day,
    month: month,
    year: year,
    now: _now,
  );
}

void main() {
  group('الأجزاء الناقصة', () {
    test('أي جزء ناقص بيرجع missing', () {
      expect(_validate(day: 1, month: 1), BirthDateError.missing);
      expect(_validate(day: 1, year: 2000), BirthDateError.missing);
      expect(_validate(month: 1, year: 2000), BirthDateError.missing);
      expect(_validate(), BirthDateError.missing);
    });
  });

  group('السنة', () {
    test('أقدم من 1900 مرفوضة', () {
      expect(_validate(day: 1, month: 1, year: 1899), BirthDateError.invalidYear);
      expect(_validate(day: 1, month: 1, year: 1900), isNull);
    });

    test('أحدث من الحد الأقصى مرفوضة', () {
      // 2026 - 14 = 2012
      expect(BirthDate.maxAllowedYear(_now), 2012);
      expect(_validate(day: 1, month: 1, year: 2013), BirthDateError.invalidYear);
    });
  });

  group('الشهر', () {
    test('خارج 1..12 مرفوض', () {
      expect(_validate(day: 1, month: 0, year: 2000), BirthDateError.invalidMonth);
      expect(_validate(day: 1, month: 13, year: 2000), BirthDateError.invalidMonth);
    });
  });

  group('صحة التاريخ التقويمي', () {
    test('31 بشهر فيه 30 يوم مرفوض', () {
      expect(_validate(day: 31, month: 4, year: 2000), BirthDateError.invalidDate);
    });

    test('29 شباط بسنة كبيسة مقبول، وبسنة عادية مرفوض', () {
      expect(_validate(day: 29, month: 2, year: 2000), isNull);
      expect(_validate(day: 29, month: 2, year: 2001), BirthDateError.invalidDate);
    });
  });

  group('الحد الأدنى للعمر', () {
    test('عمر 14 بالضبط مقبول', () {
      expect(_validate(day: 29, month: 7, year: 2012), isNull);
    });

    test('أصغر من 14 بيوم واحد مرفوض', () {
      expect(_validate(day: 30, month: 7, year: 2012), BirthDateError.tooYoung);
    });
  });

  group('daysInMonth', () {
    test('بتتعامل مع السنة الكبيسة', () {
      expect(BirthDate.daysInMonth(2000, 2), 29);
      expect(BirthDate.daysInMonth(2001, 2), 28);
      expect(BirthDate.daysInMonth(2001, 4), 30);
      expect(BirthDate.daysInMonth(2001, 12), 31);
    });
  });

  group('apiFormat', () {
    test('بتطابق الشكل الموثّق YYYY/M/D بلا تصفير', () {
      expect(const BirthDate(day: 1, month: 2, year: 2003).apiFormat, '2003/2/1');
      expect(
        const BirthDate(day: 25, month: 12, year: 1999).apiFormat,
        '1999/12/25',
      );
    });
  });
}
