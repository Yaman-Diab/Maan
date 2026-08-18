import 'package:flutter_test/flutter_test.dart';
import 'package:maan/features/projects/data/models/municipal_project_model.dart';
import 'package:maan/features/projects/domain/entities/project_reaction.dart';

void main() {
  group('fromMap — إحصائيات التصويت المؤكّدة من GET /api/project/votable', () {
    test('يقرأ الحقول الأساسية صح', () {
      final model = MunicipalProjectModel.fromMap({
        'id': 1,
        'name': 'إعادة تأهيل حديقة الحيّ',
        'description': 'تجديد المساحات الخضراء',
        'requires_volunteers': true,
        'volunteers_needed': 7,
        'requires_donations': true,
        'total_votes': 24,
        'weighted_yes_votes': 18.5,
        'weighted_no_votes': 5.5,
      });

      expect(model.entity.id, 1);
      expect(model.entity.title, 'إعادة تأهيل حديقة الحيّ');
      expect(model.entity.volunteersNeeded, 7);
      expect(model.entity.requiresVolunteers, isTrue);
      expect(model.entity.requiresDonations, isTrue);
      expect(model.entity.totalVotes, 24);
      expect(model.entity.weightedYesVotes, 18.5);
      expect(model.entity.weightedOpposeVotes, 5.5);
      expect(model.entity.hasActions, isTrue);
    });

    test('id/name ناقصة → FormatException', () {
      expect(
        () => MunicipalProjectModel.fromMap({'name': 'x'}),
        throwsFormatException,
      );
      expect(
        () => MunicipalProjectModel.fromMap({'id': 1}),
        throwsFormatException,
      );
    });

    test('`0`/`1` و"true" بتنقرأ كـbool — Laravel ما بيرجّع bool دايماً', () {
      final numeric = MunicipalProjectModel.fromMap({
        'id': 1,
        'name': 'x',
        'requires_donations': 1,
        'requires_volunteers': 0,
      });
      expect(numeric.entity.requiresDonations, isTrue);
      expect(numeric.entity.requiresVolunteers, isFalse);

      final stringy = MunicipalProjectModel.fromMap({
        'id': 1,
        'name': 'x',
        'requires_donations': 'true',
      });
      expect(stringy.entity.requiresDonations, isTrue);
    });

    test(
      'العدد بينتجاهل لو المشروع ما بده تطوع — بلاها بتبيّن البطاقة كأنها بتطلب',
      () {
        final model = MunicipalProjectModel.fromMap({
          'id': 1,
          'name': 'x',
          'requires_volunteers': false,
          // قيمة قديمة محفوظة من إعداد سابق.
          'volunteers_needed': 5,
        });

        expect(model.entity.volunteersNeeded, isNull);
        expect(model.entity.requiresVolunteers, isFalse);
      },
    );

    test('بلا تطوع ولا تبرع → hasActions false (بطاقة بلا أزرار)', () {
      final model = MunicipalProjectModel.fromMap({'id': 1, 'name': 'x'});

      expect(model.entity.hasActions, isFalse);
      expect(model.entity.totalVotes, 0);
      expect(model.entity.weightedYesVotes, 0);
      expect(model.entity.weightedOpposeVotes, 0);
      expect(model.entity.myReaction, ProjectReaction.none);
    });

    test(
      'has_voted/my_vote بتبني myReaction — favor لو true، oppose لو false',
      () {
        final favor = MunicipalProjectModel.fromMap({
          'id': 1,
          'name': 'x',
          'has_voted': true,
          'my_vote': true,
        });
        expect(favor.entity.myReaction, ProjectReaction.favor);
        expect(favor.entity.hasVoted, isTrue);

        final oppose = MunicipalProjectModel.fromMap({
          'id': 1,
          'name': 'x',
          'has_voted': true,
          'my_vote': false,
        });
        expect(oppose.entity.myReaction, ProjectReaction.oppose);

        final none = MunicipalProjectModel.fromMap({
          'id': 1,
          'name': 'x',
          'has_voted': false,
        });
        expect(none.entity.myReaction, ProjectReaction.none);
        expect(none.entity.hasVoted, isFalse);
      },
    );

    test(
      'has_voted true بلا my_vote (شكل مشوَّه) → none دفاعياً بدل تخمين قيمة',
      () {
        final model = MunicipalProjectModel.fromMap({
          'id': 1,
          'name': 'x',
          'has_voted': true,
        });

        expect(model.entity.myReaction, ProjectReaction.none);
      },
    );

    test('الموقع ككائن متداخل أو مسطّح', () {
      final nested = MunicipalProjectModel.fromMap({
        'id': 1,
        'name': 'x',
        'location': {'latitude': '33.5138000', 'longitude': '36.2765000'},
      });
      expect(nested.entity.latitude, 33.5138);
      expect(nested.entity.hasLocation, isTrue);

      final none = MunicipalProjectModel.fromMap({'id': 1, 'name': 'x'});
      expect(none.entity.hasLocation, isFalse);
    });
  });

  group('listFromResponse', () {
    test('قائمة تحت data', () {
      final result = MunicipalProjectModel.listFromResponse({
        'data': [
          {'id': 1, 'name': 'a'},
          {'id': 2, 'name': 'b'},
        ],
      });

      expect(result.length, 2);
    });

    test('عنصر غلط بينترمى بصمت', () {
      final result = MunicipalProjectModel.listFromResponse([
        {'id': 1, 'name': 'a'},
        {'name': 'ناقص id'},
        {'id': 3, 'name': 'c'},
      ]);

      expect(result.map((p) => p.id), [1, 3]);
    });
  });
}
