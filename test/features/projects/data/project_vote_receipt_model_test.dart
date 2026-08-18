import 'package:flutter_test/flutter_test.dart';
import 'package:maan/features/projects/data/models/project_vote_receipt_model.dart';

void main() {
  group('ProjectVoteReceiptModel.fromResponse', () {
    test('يقرأ استجابة POST /api/project/vote/{id} الحقيقية', () {
      final model = ProjectVoteReceiptModel.fromResponse({
        'status': 1,
        'message': 'vote recorded successfully',
        'data': {
          'project_id': 3,
          'user_id': 12,
          'value': true,
          'citizenship_score_at_vote_time': 40,
          'vote_weight': 7.32,
          'id': 55,
          'updated_at': '2026-08-18T00:00:00.000000Z',
          'created_at': '2026-08-18T00:00:00.000000Z',
        },
      });

      expect(model.entity.projectId, 3);
      expect(model.entity.value, isTrue);
      expect(model.entity.voteWeight, 7.32);
      expect(model.entity.citizenshipScoreAtVoteTime, 40);
    });

    test('بلا data → FormatException', () {
      expect(
        () => ProjectVoteReceiptModel.fromResponse({'status': 1}),
        throwsFormatException,
      );
    });

    test('project_id أو value ناقصين → FormatException', () {
      expect(
        () => ProjectVoteReceiptModel.fromResponse({
          'data': {'value': true},
        }),
        throwsFormatException,
      );
      expect(
        () => ProjectVoteReceiptModel.fromResponse({
          'data': {'project_id': 1},
        }),
        throwsFormatException,
      );
    });
  });
}
