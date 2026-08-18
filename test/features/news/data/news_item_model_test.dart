import 'package:flutter_test/flutter_test.dart';
import 'package:maan/features/news/data/models/news_item_model.dart';

void main() {
  group('fromMap — الحقول المتوقّعة (بلا عقد باك اند بعد)', () {
    test('يقرأ الحقول الأساسية صح', () {
      final model = NewsItemModel.fromMap({
        'id': 4,
        'title': 'افتتاح المركز الصحي',
        'description': 'وصف الخبر',
        'image_url': 'https://x/news.jpg',
        'published_at': '2026-08-16T09:00:00.000000Z',
      });

      expect(model.entity.id, 4);
      expect(model.entity.title, 'افتتاح المركز الصحي');
      expect(model.entity.description, 'وصف الخبر');
      expect(model.entity.imageUrl, 'https://x/news.jpg');
      expect(model.entity.hasImage, isTrue);
      expect(model.entity.publishedAt, isNotNull);
    });

    test('id/title ناقصة → FormatException', () {
      expect(
        () => NewsItemModel.fromMap({'title': 'x'}),
        throwsFormatException,
      );
      expect(() => NewsItemModel.fromMap({'id': 1}), throwsFormatException);
    });

    test('بلا صورة → hasImage false بلا انهيار', () {
      final model = NewsItemModel.fromMap({'id': 1, 'title': 'x'});

      expect(model.entity.hasImage, isFalse);
      expect(model.entity.imageUrl, isNull);
    });

    test('⚠️ الصورة من media[] لا من حقل مسطّح — الشكل الحقيقي المؤكّد', () {
      final model = NewsItemModel.fromMap({
        'id': 1,
        'title': 'x',
        'type': 'news',
        'media': [
          {
            'id': 1,
            'file_path': 'news/images/x.jpg',
            'media_type': 'image',
            'file_url': 'http://srv/storage/news/images/x.jpg',
          },
        ],
      });

      expect(model.entity.imageUrl, 'http://srv/storage/news/images/x.jpg');
      expect(model.entity.hasImage, isTrue);
    });

    test('فيديو بالمصفوفة بينتخطّى — البطاقة بتعرض صورة بس', () {
      final model = NewsItemModel.fromMap({
        'id': 1,
        'title': 'x',
        'media': [
          {'file_url': 'http://srv/v.mp4', 'media_type': 'video'},
          {'file_url': 'http://srv/a.jpg', 'media_type': 'image'},
        ],
      });

      expect(model.entity.imageUrl, 'http://srv/a.jpg');
    });

    test('الموقع ككائن متداخل (location أو pin) أو مسطّح', () {
      final nested = NewsItemModel.fromMap({
        'id': 1,
        'title': 'x',
        'location': {'latitude': '33.5138000', 'longitude': '36.2765000'},
      });
      expect(nested.entity.latitude, 33.5138);
      expect(nested.entity.hasLocation, isTrue);

      final pin = NewsItemModel.fromMap({
        'id': 1,
        'title': 'x',
        'pin': {'latitude': 1.5, 'longitude': 2.5},
      });
      expect(pin.entity.longitude, 2.5);

      final flat = NewsItemModel.fromMap({
        'id': 1,
        'title': 'x',
        'latitude': 3.5,
        'longitude': 4.5,
      });
      expect(flat.entity.latitude, 3.5);

      final none = NewsItemModel.fromMap({'id': 1, 'title': 'x'});
      expect(none.entity.hasLocation, isFalse);
    });

    test('تاريخ النشر بيجرّب published_at ثم created_at', () {
      final published = NewsItemModel.fromMap({
        'id': 1,
        'title': 'x',
        'published_at': '2026-08-16T09:00:00.000Z',
        'created_at': '2026-01-01T00:00:00.000Z',
      });
      expect(
        published.entity.publishedAt,
        DateTime.parse('2026-08-16T09:00:00.000Z'),
      );

      final created = NewsItemModel.fromMap({
        'id': 1,
        'title': 'x',
        'created_at': '2026-01-01T00:00:00.000Z',
      });
      expect(
        created.entity.publishedAt,
        DateTime.parse('2026-01-01T00:00:00.000Z'),
      );
    });
  });

  group('listFromResponse — أشكال تغليف مختلفة', () {
    test('قائمة تحت data (الشكل المتوقّع)', () {
      final result = NewsItemModel.listFromResponse({
        'status': 1,
        'data': [
          {'id': 1, 'title': 'a'},
          {'id': 2, 'title': 'b'},
        ],
      });

      expect(result.length, 2);
    });

    test('قائمة مباشرة', () {
      final result = NewsItemModel.listFromResponse([
        {'id': 1, 'title': 'a'},
      ]);

      expect(result.length, 1);
    });

    test('عنصر غلط بينترمى بصمت بدل ما يوقّع القائمة كلها', () {
      final result = NewsItemModel.listFromResponse([
        {'id': 1, 'title': 'a'},
        {'title': 'ناقص id'},
        {'id': 3, 'title': 'c'},
      ]);

      expect(result.map((n) => n.id), [1, 3]);
    });
  });
}
