// -------------------------
// Skill Model
// -------------------------

import '../../../../core/network/api_response_keys.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/skill_type.dart';

/// قراءة عنصر مهارة من `GET /api/skill/`.
///
/// ⚠️ **الشكل غير مؤكّد بمثال استجابة حقيقي** — الـcollection عندها
/// مثال الإرسال (`name`+`type`) بس. `id`/`name`/`type` مفروضة تتطابق
/// لأنها نفس أسماء الإرسال؛ `created_at` مخمَّن (اصطلاح Laravel قياسي)
/// وبيرجع `null` لو غايب بدل ما يفشّل العنصر كامل.
class SkillModel {
  final Skill entity;

  const SkillModel(this.entity);

  factory SkillModel.fromMap(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'] as String?;
    final type = SkillType.fromApi(json['type'] as String?);

    if (id is! int || name == null || type == null) {
      throw const FormatException('Skill data is missing required fields.');
    }

    return SkillModel(
      Skill(
        id: id,
        name: name,
        type: type,
        createdAt: _tryParseDate(json['created_at']),
      ),
    );
  }

  static List<Skill> listFromResponse(dynamic response) {
    final result = <Skill>[];

    for (final item in _extractList(response)) {
      if (item is! Map) continue;

      try {
        result.add(SkillModel.fromMap(Map<String, dynamic>.from(item)).entity);
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

  static DateTime? _tryParseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;

    return DateTime.tryParse(value);
  }
}
