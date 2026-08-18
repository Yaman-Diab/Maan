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

    test('بلا تطوع ولا تبرع بالاستجابة → قيم افتراضية آمنة', () {
      final model = MunicipalProjectModel.fromMap({'id': 1, 'name': 'x'});

      expect(model.entity.requiresVolunteers, isFalse);
      expect(model.entity.requiresDonations, isFalse);
      expect(model.entity.totalVotes, 0);
      expect(model.entity.weightedYesVotes, 0);
      expect(model.entity.weightedOpposeVotes, 0);
      expect(model.entity.myReaction, ProjectReaction.none);
    });

    group('my_vote — كائن حقيقي لا bool (باگ حقيقي انصلح)', () {
      test('⚠️ my_vote كائن {value:true,...} — الشكل الحقيقي المؤكّد من '
          'GET /api/project/votable، مش true/false مباشرة', () {
        final favor = MunicipalProjectModel.fromMap({
          'id': 3,
          'name': 'بلدية',
          'has_voted': true,
          'my_vote': {
            'id': 3,
            'project_id': 3,
            'user_id': 1,
            'value': true,
            'citizenship_score_at_vote_time': 100,
            'vote_weight': '11.0000',
            'created_at': '2026-08-18T03:16:33.000000Z',
            'updated_at': '2026-08-18T03:16:33.000000Z',
          },
        });

        // قبل الإصلاح كانت ترجع oppose — كائن مش bool/num/String
        // فـ_asBool كانت ترجع false افتراضياً، وbool false != null
        // فيتفرّع لـ«oppose» رغم إن value الحقيقية true.
        expect(favor.entity.myReaction, ProjectReaction.favor);
        expect(favor.entity.hasVoted, isTrue);
      });

      test('my_vote بـvalue:false → oppose', () {
        final oppose = MunicipalProjectModel.fromMap({
          'id': 1,
          'name': 'x',
          'has_voted': true,
          'my_vote': {'value': false},
        });

        expect(oppose.entity.myReaction, ProjectReaction.oppose);
      });

      test('my_vote: null و has_voted: false → none', () {
        final none = MunicipalProjectModel.fromMap({
          'id': 1,
          'name': 'x',
          'has_voted': false,
          'my_vote': null,
        });

        expect(none.entity.myReaction, ProjectReaction.none);
        expect(none.entity.hasVoted, isFalse);
      });

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
    });

    test('user بالاستجابة ما بينقرأ لأي حقل — صاحب المشروع محذوف كلياً', () {
      final model = MunicipalProjectModel.fromMap({
        'id': 3,
        'name': 'بلدية',
        'user': {
          'id': 2,
          'first_name': 'adminUser 1',
          'last_name': 'User 1',
          'email': 'admin1@gmail.com',
          'national_id': '22345678901',
          'profile': {
            'id': 2,
            'user_id': 2,
            'image': 'https://randomuser.me/api/portraits/men/32.jpg',
          },
        },
      });

      expect(model.entity.id, 3);
      expect(model.entity.title, 'بلدية');
    });

    test('type/status/is_votable/budget مؤكّدة من مثال استجابة حقيقي', () {
      final model = MunicipalProjectModel.fromMap({
        'id': 3,
        'name': 'x',
        'type': 'municipal',
        'status': 'submitted',
        'is_votable': true,
        'budget': 1000000,
      });

      expect(model.entity.type, 'municipal');
      expect(model.entity.status, 'submitted');
      expect(model.entity.isVotable, isTrue);
      expect(model.entity.budget, 1000000);
    });

    test('requirements[] — تفصيل كل مهارة على حدة، بديل الرقم الإجمالي', () {
      final model = MunicipalProjectModel.fromMap({
        'id': 1,
        'name': 'x',
        'requirements': [
          {
            'id': 1,
            'skill_name': 'كهربائي',
            'skill_type': 'technical',
            'required_count': 5,
            'is_need_certificate': true,
            'approved_count': 2,
            'remaining_count': 3,
          },
        ],
      });

      final requirement = model.entity.requirements.single;
      expect(requirement.id, 1);
      expect(requirement.skillName, 'كهربائي');
      expect(requirement.skillType, 'technical');
      expect(requirement.requiredCount, 5);
      expect(requirement.isNeedCertificate, isTrue);
      expect(requirement.approvedCount, 2);
      expect(requirement.remainingCount, 3);
    });

    test('عنصر requirement بلا id/skill_name بينترمى بصمت', () {
      final model = MunicipalProjectModel.fromMap({
        'id': 1,
        'name': 'x',
        'requirements': [
          {'id': 1, 'skill_name': 'a'},
          {'skill_name': 'ناقص id'},
        ],
      });

      expect(model.entity.requirements.length, 1);
    });

    test('voting_ends_at و approval_percentage', () {
      final withDeadline = MunicipalProjectModel.fromMap({
        'id': 3,
        'name': 'x',
        'voting_status': 'active',
        'voting_ends_at': '2026-08-19T10:14:00.000000Z',
        'approval_percentage': 100,
      });

      expect(withDeadline.entity.votingStatus, 'active');
      expect(
        withDeadline.entity.votingEndsAt,
        DateTime.parse('2026-08-19T10:14:00.000000Z'),
      );
      expect(withDeadline.entity.approvalPercentage, 100);

      final withoutDeadline = MunicipalProjectModel.fromMap({
        'id': 2,
        'name': 'x',
        'voting_ends_at': null,
      });
      expect(withoutDeadline.entity.votingEndsAt, isNull);
    });

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

    test('✅ is_voluntary/is_donation/total_required_volunteers مؤكّدة من '
        'ProjectService::formatProject — أسماء حقيقية لا تخمين', () {
      final model = MunicipalProjectModel.fromMap({
        'id': 1,
        'name': 'x',
        'is_voluntary': true,
        'is_donation': true,
        'total_required_volunteers': 12,
        'total_approved_volunteers': 3,
      });

      expect(model.entity.requiresVolunteers, isTrue);
      expect(model.entity.requiresDonations, isTrue);
      expect(model.entity.volunteersNeeded, 12);
      expect(model.entity.volunteersApproved, 3);
    });

    test('⚠️ العدّ المعتمَد بيتجاهَل لو is_voluntary مطفي — قيمة قديمة '
        'محفوظة كانت رح تبيّن البطاقة كأنها بتطلب متطوعين', () {
      final model = MunicipalProjectModel.fromMap({
        'id': 1,
        'name': 'x',
        'is_voluntary': false,
        'total_required_volunteers': 5,
        'total_approved_volunteers': 2,
      });

      expect(model.entity.volunteersNeeded, isNull);
      expect(model.entity.volunteersApproved, isNull);
    });

    test('صورة المشروع من media[] — نفس شكل وسائط الشكاوى/الأخبار', () {
      final model = MunicipalProjectModel.fromMap({
        'id': 1,
        'name': 'x',
        'media': [
          {
            'id': 1,
            'file_path': 'uploads/projects/a.jpg',
            'media_type': 'image',
            'file_url': 'http://x/storage/uploads/projects/a.jpg',
          },
        ],
      });

      expect(model.entity.imageUrl, 'http://x/storage/uploads/projects/a.jpg');
    });
  });

  group(
    'detailFromResponse — GET /api/project/{id} (شكل ProjectService::show)',
    () {
      Map<String, dynamic> realDetailResponse() {
        return {
          'status': 1,
          'message': 'project retrieved successfully',
          'data': {
            'id': 3,
            'name': 'بلدية',
            'description': 'بلدية المعضمية',
            'is_voluntary': true,
            'is_donation': true,
            'latitude': '33.5138000',
            'longitude': '36.2765000',
            'budget': 1000000,
            'total_required_volunteers': 7,
            'total_approved_volunteers': 2,
            'media': [
              {
                'id': 1,
                'file_path': 'uploads/projects/x.jpg',
                'media_type': 'image',
                'file_url': 'http://x/storage/uploads/projects/x.jpg',
              },
            ],
          },
        };
      }

      test('يقرأ الحقول الناقصة من votable صح', () {
        final entity = MunicipalProjectModel.detailFromResponse(
          realDetailResponse(),
        ).entity;

        expect(entity.id, 3);
        expect(entity.requiresVolunteers, isTrue);
        expect(entity.requiresDonations, isTrue);
        expect(entity.volunteersNeeded, 7);
        expect(entity.volunteersApproved, 2);
        expect(entity.latitude, 33.5138);
        expect(entity.longitude, 36.2765);
        expect(entity.imageUrl, 'http://x/storage/uploads/projects/x.jpg');
      });

      test('بلا data → FormatException', () {
        expect(
          () => MunicipalProjectModel.detailFromResponse({'status': 1}),
          throwsFormatException,
        );
      });
    },
  );

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
