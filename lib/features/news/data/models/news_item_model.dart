// -------------------------
// News Item Model
// -------------------------

import '../../../../core/network/api_media.dart';
import '../../../../core/network/api_response_keys.dart';
import '../../domain/entities/news_item.dart';

/// قراءة عنصر خبر من `GET /api/news` — ✅ **الشكل مؤكّد** (`id`،
/// `title`، `description`، `type`، `published_at`، `location`،
/// `media[]`).
///
/// ⚠️ **الصورة جوّا `media[]` لا بحقل مسطّح** — كان الموديل بيدوّر على
/// `image_url`/`image` بالجذر (تخمين قبل وصول العقد)، فالصورة كانت رح
/// تختفي كلياً رغم وصولها. نفس شكل وسائط الشكاوى بالضبط، فالقراءة
/// انتقلت لـ`ApiMedia` المشترك.
///
/// ⚠️ **`media_type: 'image'` مفلترة صراحةً** — بطاقة الخبر بتعرض
/// صورة واحدة عبر `Image.network`، فعنصر فيديو أول بالمصفوفة كان رح
/// يوصلها ويفشل تحميله بصمت.
///
/// ⚠️ **حقل `type` (`news`/`announcement`) متجاهَل عمداً** — التطبيق ما
/// بيفرّق بينهم (قرار صريح من صاحب المشروع: «نفس الشي»)، و`NewsItem`
/// ما فيها الحقل أصلاً حتى ما يغري حدا يعرضه.
class NewsItemModel {
  final NewsItem entity;

  const NewsItemModel(this.entity);

  factory NewsItemModel.fromMap(Map<String, dynamic> json) {
    final id = json['id'];
    final title = _firstString(json, const ['title', 'name']);

    if (id is! int || title == null) {
      throw const FormatException('News data is missing required fields.');
    }

    final position = _asMap(json['location']) ?? _asMap(json['pin']);

    return NewsItemModel(
      NewsItem(
        id: id,
        title: title,
        description: _firstString(json, const [
          'description',
          'body',
          'content',
        ]),
        // `media[]` أولاً (الشكل المؤكّد)، والحقول المسطّحة خط دفاع
        // احتياطي لو رجع مسار تاني شكلاً أبسط.
        imageUrl:
            ApiMedia.firstUrl(json['media'], onlyType: ApiMedia.imageType) ??
            _firstString(json, const [
              'image_url',
              'image',
              'file_url',
              'photo',
            ]),
        publishedAt: _tryParseDate(
          json['published_at'] ?? json['created_at'] ?? json['approved_at'],
        ),
        latitude: _asDouble(position?['latitude'] ?? json['latitude']),
        longitude: _asDouble(position?['longitude'] ?? json['longitude']),
      ),
    );
  }

  static List<NewsItem> listFromResponse(dynamic response) {
    final result = <NewsItem>[];

    for (final item in _extractList(response)) {
      if (item is! Map) continue;

      try {
        result.add(
          NewsItemModel.fromMap(Map<String, dynamic>.from(item)).entity,
        );
      } on FormatException {
        continue;
      }
    }

    return result;
  }

  static List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;

    if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      final data = map[ApiResponseKeys.data];

      if (data != null) return _extractList(data);
    }

    return const [];
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);

    return null;
  }

  static String? _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }

    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);

    return null;
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;

    return DateTime.tryParse(value);
  }
}
