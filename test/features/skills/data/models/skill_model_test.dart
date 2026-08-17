import 'package:flutter_test/flutter_test.dart';
import 'package:maan/features/skills/data/models/skill_model.dart';
import 'package:maan/features/skills/domain/entities/skill_type.dart';

void main() {
  group('fromMap — الحقول المؤكّدة من عقد الإرسال', () {
    test('يقرأ الحقول الأساسية صح', () {
      final model = SkillModel.fromMap({
        'id': 7,
        'name': 'صيانة كهربائية',
        'type': 'technical',
        'created_at': '2025-01-10T10:00:00.000Z',
      });

      expect(model.entity.id, 7);
      expect(model.entity.name, 'صيانة كهربائية');
      expect(model.entity.type, SkillType.technical);
      expect(model.entity.createdAt, isNotNull);
    });

    test('id/name/type ناقصة → FormatException', () {
      expect(
        () => SkillModel.fromMap({'name': 'x', 'type': 'technical'}),
        throwsFormatException,
      );
      expect(
        () => SkillModel.fromMap({'id': 1, 'type': 'technical'}),
        throwsFormatException,
      );
      expect(
        () => SkillModel.fromMap({'id': 1, 'name': 'x'}),
        throwsFormatException,
      );
    });

    test('نوع غير معروف بيرمي — إلزامي بلا قيمة افتراضية', () {
      expect(
        () => SkillModel.fromMap({'id': 1, 'name': 'x', 'type': 'weird_type'}),
        throwsFormatException,
      );
    });

    test('created_at غايب → null بدل ما يفشّل العنصر', () {
      final model = SkillModel.fromMap({'id': 1, 'name': 'x', 'type': 'other'});

      expect(model.entity.createdAt, isNull);
    });
  });

  group('listFromResponse — أشكال تغليف مختلفة', () {
    test('قائمة مباشرة', () {
      final result = SkillModel.listFromResponse([
        {'id': 1, 'name': 'a', 'type': 'technical'},
        {'id': 2, 'name': 'b', 'type': 'social'},
      ]);

      expect(result.length, 2);
    });

    test('قائمة تحت data', () {
      final result = SkillModel.listFromResponse({
        'data': [
          {'id': 1, 'name': 'a', 'type': 'technical'},
        ],
      });

      expect(result.length, 1);
    });

    test('عنصر غلط بينترمى بصمت بدل ما يوقّع القائمة كلها', () {
      final result = SkillModel.listFromResponse([
        {'id': 1, 'name': 'a', 'type': 'technical'},
        {'name': 'ناقص id', 'type': 'technical'},
        {'id': 3, 'name': 'c', 'type': 'technical'},
      ]);

      expect(result.length, 2);
      expect(result.map((s) => s.id), [1, 3]);
    });
  });
}
