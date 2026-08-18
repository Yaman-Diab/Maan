// -------------------------
// Api Media
// -------------------------

import '../config/app_config.dart';

/// قراءة روابط الوسائط من مصفوفة `media` — شكل موحّد بين الشكاوى
/// والأخبار (`[{id, file_path, media_type, file_url}]`).
///
/// انكتب مشترك بـ`core` لأن **نفس الباگ تكرّر مرتين**: الشكاوى كانت
/// تفقد الصور لما رجع `POST /api/complains` بـ`file_path` بلا
/// `file_url`، والأخبار كانت رح تفقدها كلياً لأن موديلها كان بيدوّر
/// على حقل صورة **مسطّح** (`image_url`) بينما الصورة جايّة جوّا
/// `media[]`. توحيدها بمكان واحد بيمنع التكرار الثالث.
class ApiMedia {
  ApiMedia._();

  /// قيم `media_type` المعروفة.
  static const String imageType = 'image';

  /// كل الروابط بمصفوفة الوسائط.
  ///
  /// [onlyType] بتفلتر حسب `media_type` (مثلاً صور بس) — لازمة لما
  /// الواجهة بتعرض صورة: عنصر فيديو أول بالمصفوفة كان رح يوصل لـ
  /// `Image.network` فيفشل تحميله بصمت.
  static List<String> urls(dynamic media, {String? onlyType}) {
    if (media is! List) return const [];

    final result = <String>[];

    for (final item in media) {
      if (item is! Map) continue;

      final map = Map<String, dynamic>.from(item);

      if (onlyType != null && map['media_type'] != onlyType) continue;

      final url = _urlOf(map);
      if (url != null) result.add(url);
    }

    return result;
  }

  /// أول رابط مطابق، أو `null`.
  static String? firstUrl(dynamic media, {String? onlyType}) {
    final all = urls(media, onlyType: onlyType);

    return all.isEmpty ? null : all.first;
  }

  /// `file_url` (رابط كامل) مفضّل دائماً؛ `file_path` (مسار نسبي)
  /// بيتحوّل لرابط عبر [_storageUrl].
  ///
  /// ⚠️ **الاثنان ضروريان**: استجابة القراءة (`my-complains`، قائمة
  /// الأخبار) بترجّع `file_url` جاهزاً، بينما استجابة الإنشاء
  /// (`POST /api/complains`) بترجّع `file_path` بس — باگ حقيقي كانت
  /// الصور تختفي فيه بعد الإرسال مباشرة.
  static String? _urlOf(Map<String, dynamic> item) {
    for (final key in const ['file_url', 'url', 'image_url']) {
      final value = item[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }

    final path = item['file_path'];
    if (path is String && path.trim().isNotEmpty) return _storageUrl(path);

    return null;
  }

  /// اصطلاح Laravel القياسي لقرص `public` — مطابق للـ`file_url` يلي
  /// بيولّده الباك اند نفسه (تأكّدنا بمقارنة حرفية).
  static String _storageUrl(String relativePath) {
    final base = AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = relativePath.replaceAll(RegExp(r'^/+'), '');

    return '$base/storage/$path';
  }
}
