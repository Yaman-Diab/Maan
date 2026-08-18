import 'package:flutter_test/flutter_test.dart';
import 'package:maan/features/projects/data/models/project_donation_stats_model.dart';

void main() {
  group('fromResponse — الشكل الحقيقي المؤكّد', () {
    test('يقرأ الحقول الخمسة صح', () {
      final model = ProjectDonationStatsModel.fromResponse({
        'status': 1,
        'message': 'donation statistics retrieved successfully',
        'data': {
          'total_donated': 650000,
          'donation_target': 1000000,
          'remaining_amount': 350000,
          'donation_percentage': 65,
          'number_of_donors': 42,
        },
      });

      expect(model.entity.totalDonated, 650000);
      expect(model.entity.donationTarget, 1000000);
      expect(model.entity.remainingAmount, 350000);
      expect(model.entity.donationPercentage, 65);
      expect(model.entity.numberOfDonors, 42);
      expect(model.entity.hasTarget, isTrue);
      expect(model.entity.isFunded, isFalse);
    });

    test('بلا data → FormatException', () {
      expect(
        () => ProjectDonationStatsModel.fromResponse({'status': 1}),
        throwsFormatException,
      );
    });

    test('مبالغ كنص عشري بتنقرأ — Laravel بيرجّعها هيك أحياناً', () {
      final model = ProjectDonationStatsModel.fromResponse({
        'data': {
          'total_donated': '650000.00',
          'donation_target': '1000000.00',
          'donation_percentage': '65.00',
        },
      });

      expect(model.entity.totalDonated, 650000);
      expect(model.entity.donationTarget, 1000000);
      // النسبة `int` بالكيان — التقريب مقصود لأن العرض «65%» لا «65.0%».
      expect(model.entity.donationPercentage, 65);
    });
  });

  group('حالة «بلا ميزانية محدّدة» — الحافة المهمة', () {
    test('target/remaining بيضلّوا null (لا صفر) والنسبة صفر', () {
      final model = ProjectDonationStatsModel.fromResponse({
        'data': {
          'total_donated': 5000,
          'donation_target': null,
          'remaining_amount': null,
          'donation_percentage': 0,
          'number_of_donors': 3,
        },
      });

      // ⚠️ التفريق الحاسم: «بلا هدف» مش «هدف صفر» ولا «صفر تبرعات» —
      // الواجهة بتخفي شريط التقدّم بناءً على هاد بالضبط.
      expect(model.entity.donationTarget, isNull);
      expect(model.entity.remainingAmount, isNull);
      expect(model.entity.hasTarget, isFalse);
      expect(model.entity.isFunded, isFalse);
      expect(model.entity.totalDonated, 5000);
    });

    test('هدف بصفر بيتعامل كـ«بلا هدف» — قسمة على صفر منطقياً', () {
      final model = ProjectDonationStatsModel.fromResponse({
        'data': {'total_donated': 100, 'donation_target': 0},
      });

      expect(model.entity.hasTarget, isFalse);
    });
  });

  group('اكتمال الهدف', () {
    test('100% → isFunded', () {
      final model = ProjectDonationStatsModel.fromResponse({
        'data': {
          'total_donated': 1000000,
          'donation_target': 1000000,
          'remaining_amount': 0,
          'donation_percentage': 100,
        },
      });

      expect(model.entity.isFunded, isTrue);
    });

    test('حقول ناقصة كلياً → أصفار بلا انهيار', () {
      final model = ProjectDonationStatsModel.fromResponse({
        'data': <String, dynamic>{},
      });

      expect(model.entity.totalDonated, 0);
      expect(model.entity.donationPercentage, 0);
      expect(model.entity.numberOfDonors, 0);
      expect(model.entity.hasTarget, isFalse);
    });
  });
}
