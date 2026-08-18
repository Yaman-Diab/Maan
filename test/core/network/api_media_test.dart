import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/config/app_config.dart';
import 'package:maan/core/network/api_media.dart';

/// ⚠️ **بلا تثبيت لقيمة `AppConfig.baseUrl` كنص حرفي** — القيمة
/// الافتراضية بالكود نفسه معدّة عمداً لتتبدّل محلياً (`--dart-define`
/// أو تعديل مباشر وقت الاختبار على باك اند بديل زي ngrok)، فتثبيتها
/// هون كان بيخلّي الاختبار يفشل كل ما حدا يبدّل الافتراضي. `_storageUrl`
/// هون بتكرّر نفس منطق `ApiMedia._storageUrl` (قصّ الشرطة الزائدة)
/// بدل ما تفترض قيمة معيّنة.
String _storageUrl(String path) {
  final base = AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');

  return '$base/storage/$path';
}

void main() {
  group('urls — file_url مفضّل، file_path احتياطي', () {
    test('file_url كامل بينستخدم كما هو', () {
      final result = ApiMedia.urls([
        {'file_url': 'http://x/storage/a.jpg', 'file_path': 'a.jpg'},
      ]);

      expect(result, ['http://x/storage/a.jpg']);
    });

    test('⚠️ file_path لحاله (شكل POST /api/complains) بيتحوّل لرابط كامل', () {
      final result = ApiMedia.urls([
        {'file_path': 'complains/images/x.png', 'media_type': 'image'},
      ]);

      expect(result, [_storageUrl('complains/images/x.png')]);
    });

    test('بلا أي حقل رابط → العنصر بينترمى بصمت', () {
      final result = ApiMedia.urls([
        {'id': 1, 'media_type': 'image'},
        {'file_path': 'ok.jpg'},
      ]);

      expect(result, hasLength(1));
    });

    test('media مش قائمة → فاضي بلا انهيار', () {
      expect(ApiMedia.urls(null), isEmpty);
      expect(ApiMedia.urls('nonsense'), isEmpty);
      expect(ApiMedia.urls(const []), isEmpty);
    });

    test('شرطة مائلة زائدة ما بتعمل // بالرابط', () {
      final result = ApiMedia.urls([
        {'file_path': '/leading/slash.jpg'},
      ]);

      expect(result.single, _storageUrl('leading/slash.jpg'));
    });
  });

  group('فلترة النوع', () {
    test(
      '⚠️ onlyType بتتخطّى الفيديو — بطاقة الخبر بتعرض صورة بـImage.network',
      () {
        final media = [
          {'file_url': 'http://x/v.mp4', 'media_type': 'video'},
          {'file_url': 'http://x/a.jpg', 'media_type': 'image'},
        ];

        expect(
          ApiMedia.firstUrl(media, onlyType: ApiMedia.imageType),
          'http://x/a.jpg',
        );
        // بلا فلترة: الفيديو أولاً (الشكاوى بتقبله عمداً).
        expect(ApiMedia.firstUrl(media), 'http://x/v.mp4');
      },
    );

    test('ما في عنصر مطابق للنوع → null', () {
      final result = ApiMedia.firstUrl([
        {'file_url': 'http://x/v.mp4', 'media_type': 'video'},
      ], onlyType: ApiMedia.imageType);

      expect(result, isNull);
    });
  });
}
