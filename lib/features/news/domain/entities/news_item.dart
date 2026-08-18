// -------------------------
// News Item
// -------------------------

import 'package:equatable/equatable.dart';

/// خبر أو إعلان بلدي منشور.
///
/// ⚠️ **بلا حقل `type`** عن قصد — قرار صريح من صاحب المشروع: «الخبر
/// والإعلان نفس الشي»، فما في تمييز بصري ولا منطقي بينهم بتطبيق
/// المواطن. لو رجّع الباك اند حقل نوع، بينتجاهل بطبقة data بدل ما
/// يوصل للـdomain ويغري حدا يعرضه.
///
/// ⚠️ **بس المحتوى المعتمَد المنشور بيوصل هون** — الفلترة مسؤولية
/// الباك اند (المحتوى «قيد المراجعة» أو المرفوض ما بيرجع أصلاً للمواطن،
/// راجع يوزر ستوري «عرض الأخبار والإعلانات»).
final class NewsItem extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime? publishedAt;

  /// اختياريان — الخبر ممكن يكون مرتبط بموقع (يوزر ستوري AC-06).
  final double? latitude;
  final double? longitude;

  const NewsItem({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.publishedAt,
    this.latitude,
    this.longitude,
  });

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool get hasLocation => latitude != null && longitude != null;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imageUrl,
    publishedAt,
    latitude,
    longitude,
  ];
}
