import 'package:flutter_test/flutter_test.dart';
import 'package:maan/features/municipal_services/data/models/municipal_service_model.dart';

void main() {
  group('fromMap — الحقول المؤكّدة من مثال استجابة حقيقي', () {
    test('يقرأ الحقول الأساسية صح', () {
      final model = MunicipalServiceModel.fromMap({
        'id': 1,
        'name': 'Official Documents',
        'prefix': 'O',
        'qr_code_string': 'SRV-OFFDOC-001',
        'estimated_time_minutes': 10,
        'status': 'active',
        'assigned_employees': 0,
        'people_waiting': 3,
        'served_today': 0,
      });

      expect(model.entity.id, 1);
      expect(model.entity.name, 'Official Documents');
      expect(model.entity.estimatedTimeMinutes, 10);
      expect(model.entity.peopleWaiting, 3);
      expect(model.entity.isActive, isTrue);
    });

    test('id/name/estimated_time_minutes ناقصة → FormatException', () {
      expect(
        () => MunicipalServiceModel.fromMap({
          'name': 'x',
          'estimated_time_minutes': 10,
        }),
        throwsFormatException,
      );
      expect(
        () => MunicipalServiceModel.fromMap({
          'id': 1,
          'estimated_time_minutes': 10,
        }),
        throwsFormatException,
      );
      expect(
        () => MunicipalServiceModel.fromMap({'id': 1, 'name': 'x'}),
        throwsFormatException,
      );
    });

    test('status غير active (أو غايب) → isActive false', () {
      final paused = MunicipalServiceModel.fromMap({
        'id': 1,
        'name': 'x',
        'estimated_time_minutes': 10,
        'status': 'paused',
      });
      expect(paused.entity.isActive, isFalse);

      final missing = MunicipalServiceModel.fromMap({
        'id': 1,
        'name': 'x',
        'estimated_time_minutes': 10,
      });
      expect(missing.entity.isActive, isFalse);
    });

    test('people_waiting غايب → 0 بدل ما يفشّل العنصر', () {
      final model = MunicipalServiceModel.fromMap({
        'id': 1,
        'name': 'x',
        'estimated_time_minutes': 10,
      });

      expect(model.entity.peopleWaiting, 0);
    });

    test('رقم كنص بينقرأ كمان', () {
      final model = MunicipalServiceModel.fromMap({
        'id': 1,
        'name': 'x',
        'estimated_time_minutes': '10',
        'people_waiting': '3',
      });

      expect(model.entity.estimatedTimeMinutes, 10);
      expect(model.entity.peopleWaiting, 3);
    });
  });

  group('estimatedWaitMinutes — الحساب المحلي', () {
    test('estimated_time_minutes × people_waiting', () {
      final model = MunicipalServiceModel.fromMap({
        'id': 1,
        'name': 'x',
        'estimated_time_minutes': 10,
        'people_waiting': 3,
        'status': 'active',
      });

      expect(model.entity.estimatedWaitMinutes, 30);
      expect(model.entity.hasNoWait, isFalse);
    });

    test('بلا منتظرين → hasNoWait true ووقت صفر', () {
      final model = MunicipalServiceModel.fromMap({
        'id': 1,
        'name': 'x',
        'estimated_time_minutes': 10,
        'people_waiting': 0,
        'status': 'active',
      });

      expect(model.entity.estimatedWaitMinutes, 0);
      expect(model.entity.hasNoWait, isTrue);
    });
  });

  group('listFromResponse — أشكال تغليف مختلفة', () {
    test('قائمة تحت data (الشكل الحقيقي المؤكّد)', () {
      final result = MunicipalServiceModel.listFromResponse({
        'status': 1,
        'message': 'Services retrieved successfully',
        'data': [
          {'id': 1, 'name': 'a', 'estimated_time_minutes': 10},
          {'id': 2, 'name': 'b', 'estimated_time_minutes': 15},
        ],
      });

      expect(result.length, 2);
    });

    test('قائمة مباشرة', () {
      final result = MunicipalServiceModel.listFromResponse([
        {'id': 1, 'name': 'a', 'estimated_time_minutes': 10},
      ]);

      expect(result.length, 1);
    });

    test('عنصر غلط بينترمى بصمت بدل ما يوقّع القائمة كلها', () {
      final result = MunicipalServiceModel.listFromResponse([
        {'id': 1, 'name': 'a', 'estimated_time_minutes': 10},
        {'name': 'ناقص id', 'estimated_time_minutes': 10},
        {'id': 3, 'name': 'c', 'estimated_time_minutes': 10},
      ]);

      expect(result.length, 2);
      expect(result.map((s) => s.id), [1, 3]);
    });
  });
}
