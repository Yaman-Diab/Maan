import 'package:flutter_test/flutter_test.dart';
import 'package:maan/features/complaints/data/models/complaint_model.dart';
import 'package:maan/features/complaints/domain/entities/complaint_category.dart';
import 'package:maan/features/complaints/domain/entities/complaint_status.dart';
import 'package:maan/features/complaints/domain/entities/complaint_type.dart';

void main() {
  group('fromMap — الحقول المؤكّدة من عقد الإرسال', () {
    test('يقرأ الحقول الأساسية صح', () {
      final model = ComplaintModel.fromMap({
        'id': 1042,
        'type': 'emergency',
        'category_id': 3,
        'title': 'عمود كهرباء مكسور',
        'status': 'in_progress',
        'description': 'وصف الحالة',
        'latitude': 33.5138,
        'longitude': 36.2760,
      });

      expect(model.entity.id, 1042);
      expect(model.entity.type, ComplaintType.emergency);
      expect(model.entity.category, ComplaintCategory.lighting);
      expect(model.entity.status, ComplaintStatus.inProgress);
      expect(model.entity.title, 'عمود كهرباء مكسور');
      expect(model.entity.description, 'وصف الحالة');
      expect(model.entity.latitude, 33.5138);
      expect(model.entity.longitude, 36.2760);
    });

    test('id/type/title ناقصة → FormatException', () {
      expect(
        () => ComplaintModel.fromMap({'type': 'individual', 'title': 'x'}),
        throwsFormatException,
      );
      expect(
        () => ComplaintModel.fromMap({'id': 1, 'title': 'x'}),
        throwsFormatException,
      );
      expect(
        () => ComplaintModel.fromMap({'id': 1, 'type': 'individual'}),
        throwsFormatException,
      );
    });

    test('نوع غير معروف بيرمي — إلزامي بلا قيمة افتراضية', () {
      expect(
        () => ComplaintModel.fromMap({
          'id': 1,
          'type': 'weird_type',
          'title': 'x',
        }),
        throwsFormatException,
      );
    });

    test('تصنيف/حالة غير معروفَين ما بيرميوا — قيم افتراضية آمنة', () {
      final model = ComplaintModel.fromMap({
        'id': 1,
        'type': 'individual',
        'category_id': 99,
        'status': 'weird_status',
        'title': 'x',
      });

      expect(model.entity.category, isNull);
      expect(model.entity.status, ComplaintStatus.unknown);
    });
  });

  group('حقول مخمَّنة — أول اسم موجود بيُستخدم', () {
    test('votes_count أولاً، بعدين votes، بعدين vote_count', () {
      final a = ComplaintModel.fromMap({
        'id': 1,
        'type': 'individual',
        'title': 'x',
        'votes_count': 5,
      });
      expect(a.entity.votes, 5);

      final b = ComplaintModel.fromMap({
        'id': 1,
        'type': 'individual',
        'title': 'x',
        'votes': 7,
      });
      expect(b.entity.votes, 7);

      final c = ComplaintModel.fromMap({
        'id': 1,
        'type': 'individual',
        'title': 'x',
      });
      expect(c.entity.votes, 0);
    });

    test('has_voted مخمَّن بأكتر من اسم، وbool افتراضي false', () {
      final voted = ComplaintModel.fromMap({
        'id': 1,
        'type': 'individual',
        'title': 'x',
        'voted': true,
      });
      expect(voted.entity.hasVoted, isTrue);

      final notVoted = ComplaintModel.fromMap({
        'id': 1,
        'type': 'individual',
        'title': 'x',
      });
      expect(notVoted.entity.hasVoted, isFalse);
    });

    test('mediaUrls من file_url — الشكل الحقيقي المؤكّد', () {
      final withMedia = ComplaintModel.fromMap({
        'id': 1,
        'type': 'individual',
        'title': 'x',
        'media': [
          {
            'id': 1,
            'file_path': 'a.jpg',
            'media_type': 'image',
            'file_url': 'https://x/a.jpg',
          },
          {
            'id': 2,
            'file_path': 'b.jpg',
            'media_type': 'image',
            'file_url': 'https://x/b.jpg',
          },
        ],
      });
      expect(withMedia.entity.mediaUrls, [
        'https://x/a.jpg',
        'https://x/b.jpg',
      ]);
      expect(withMedia.entity.hasMedia, isTrue);

      final emptyList = ComplaintModel.fromMap({
        'id': 1,
        'type': 'individual',
        'title': 'x',
        'media': [],
      });
      expect(emptyList.entity.mediaUrls, isEmpty);
      expect(emptyList.entity.hasMedia, isFalse);

      final missing = ComplaintModel.fromMap({
        'id': 1,
        'type': 'individual',
        'title': 'x',
      });
      expect(missing.entity.hasMedia, isFalse);
    });
  });

  group('التصنيف والموقع — كائنان متداخلان (الشكل الحقيقي المؤكّد)', () {
    test('category ككائن متداخل بلا category_id مسطّح (شكل my-complains)', () {
      final model = ComplaintModel.fromMap({
        'id': 1,
        'type': 'collective',
        'title': 'x',
        'category': {'id': 2, 'name': 'Waste & Cleanliness'},
      });

      expect(model.entity.category, ComplaintCategory.waste);
    });

    test('location ككائن متداخل (شكل my-complains)', () {
      final model = ComplaintModel.fromMap({
        'id': 1,
        'type': 'individual',
        'title': 'x',
        'location': {'latitude': '33.5138000', 'longitude': '36.2760000'},
      });

      expect(model.entity.latitude, 33.5138);
      expect(model.entity.longitude, 36.276);
    });

    test('pin ككائن متداخل — نفس المفهوم باسم مختلف (شكل استجابة الإنشاء)', () {
      final model = ComplaintModel.fromMap({
        'id': 1,
        'type': 'individual',
        'title': 'x',
        'pin': {'latitude': '33.5138000', 'longitude': '36.2760000'},
      });

      expect(model.entity.latitude, 33.5138);
      expect(model.entity.longitude, 36.276);
    });

    test('category_id المسطّح لسه بيشتغل لو category الكائن غايب', () {
      final model = ComplaintModel.fromMap({
        'id': 1,
        'type': 'individual',
        'title': 'x',
        'category_id': 3,
      });

      expect(model.entity.category, ComplaintCategory.lighting);
    });
  });

  group('listFromResponse — أشكال تغليف مختلفة', () {
    test('قائمة مباشرة', () {
      final result = ComplaintModel.listFromResponse([
        {'id': 1, 'type': 'individual', 'title': 'a'},
        {'id': 2, 'type': 'collective', 'title': 'b'},
      ]);

      expect(result.length, 2);
    });

    test('قائمة تحت data', () {
      final result = ComplaintModel.listFromResponse({
        'status': 1,
        'data': [
          {'id': 1, 'type': 'individual', 'title': 'a'},
        ],
      });

      expect(result.length, 1);
    });

    test('data.data (ترقيم Laravel متداخل)', () {
      final result = ComplaintModel.listFromResponse({
        'data': {
          'data': [
            {'id': 1, 'type': 'individual', 'title': 'a'},
          ],
        },
      });

      expect(result.length, 1);
    });

    test('عنصر غلط بينترمى بصمت بدل ما يوقّع القائمة كلها', () {
      final result = ComplaintModel.listFromResponse([
        {'id': 1, 'type': 'individual', 'title': 'a'},
        {'type': 'individual', 'title': 'ناقص id'},
        {'id': 3, 'type': 'individual', 'title': 'c'},
      ]);

      expect(result.length, 2);
      expect(result.map((c) => c.id), [1, 3]);
    });

    test('isMine بتنعلّم على كل عناصر شكاواي', () {
      final result = ComplaintModel.listFromResponse([
        {'id': 1, 'type': 'individual', 'title': 'a'},
      ], isMine: true);

      expect(result.single.isMine, isTrue);
    });
  });
}
