// -------------------------
// Municipal Project Model
// -------------------------

import '../../../../core/network/api_response_keys.dart';
import '../../domain/entities/municipal_project.dart';
import '../../domain/entities/project_reaction.dart';

/// قراءة عنصر مشروع من `GET /api/project/votable`.
///
/// ✅ **حقول التصويت مؤكّدة بالكامل** بمثال حقيقي — `total_votes`،
/// `weighted_yes_votes`، `weighted_no_votes`، `approval_percentage`
/// (غير مستهلَك بالـdomain entity لعدم وجود استخدام حالي، نفس معاملة
/// `priority_score` بالشكاوى — القيمة بالاستجابة الخام لو احتجناها
/// مستقبلاً لفرز/فلترة)، `has_voted`، `my_vote`.
///
/// ⚠️ **باقي حقول المشروع (`name`/`description`/`image`/`requires_*`)
/// غير مؤكّدة بهالمسار تحديداً** — المثال يلي وصل غطّى إحصائيات
/// التصويت بس. الأسماء هون موروثة من عقد `POST /api/create` (الأقرب
/// للمؤكّد)، بس ممكن هالـendpoint يرجّع شكل مختلف كلياً أو حقول
/// التصويت بس بلا تفاصيل المشروع. `_firstString`/`_asBool` دفاعية أصلاً
/// فغياب الحقول بيرجّع `null`/`false` بلا كراش — الوصف والصورة
/// بيختفوا من الواجهة بهدوء لو الشكل الحقيقي أضيق. نقطة التصحيح لما
/// يوصل مثال كامل: هالملف + `ApiEndpoints.projectVotable`.
class MunicipalProjectModel {
  final MunicipalProject entity;

  const MunicipalProjectModel(this.entity);

  factory MunicipalProjectModel.fromMap(Map<String, dynamic> json) {
    final id = json['id'];
    final title = _firstString(json, const ['name', 'title']);

    if (id is! int || title == null) {
      throw const FormatException('Project data is missing required fields.');
    }

    final position = _asMap(json['location']) ?? _asMap(json['pin']);
    final requiresVolunteers = _asBool(json['requires_volunteers']);
    final needed = _asInt(
      json['volunteers_needed'] ?? json['required_volunteers'],
    );

    return MunicipalProjectModel(
      MunicipalProject(
        id: id,
        title: title,
        description: _firstString(json, const ['description', 'body']),
        imageUrl: _firstString(json, const [
          'image_url',
          'image',
          'file_url',
          'photo',
        ]),
        latitude: _asDouble(position?['latitude'] ?? json['latitude']),
        longitude: _asDouble(position?['longitude'] ?? json['longitude']),
        // العدد بس لو المشروع فعلاً بده تطوع — بلاها ممكن يرجع رقم
        // قديم محفوظ من إعداد سابق فتظهر البطاقة كأنها بتطلب متطوعين.
        volunteersNeeded: requiresVolunteers ? needed : null,
        requiresDonations: _asBool(json['requires_donations']),
        totalVotes: _asInt(json['total_votes']) ?? 0,
        weightedYesVotes: _asDouble(json['weighted_yes_votes']) ?? 0,
        weightedOpposeVotes: _asDouble(json['weighted_no_votes']) ?? 0,
        myReaction: ProjectReaction.fromVoteFields(
          hasVoted: _asBool(json['has_voted']),
          myVote: _asBoolOrNull(json['my_vote']),
        ),
      ),
    );
  }

  static List<MunicipalProject> listFromResponse(dynamic response) {
    final result = <MunicipalProject>[];

    for (final item in _extractList(response)) {
      if (item is! Map) continue;

      try {
        result.add(
          MunicipalProjectModel.fromMap(Map<String, dynamic>.from(item)).entity,
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

  /// الباك اند بيرجّع `0`/`1` أو `"true"` أحياناً لا `bool` دائماً —
  /// نفس ملاحظة `AuthUserModel._asBool`.
  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == 'true' || value == '1';

    return false;
  }

  /// نفس [_asBool] بس بترجّع `null` بدل `false` لو الحقل غايب —
  /// لازمة لـ`my_vote` حيث الغياب معناه مختلف عن `false` صراحة
  /// (راجع `ProjectReaction.fromVoteFields`).
  static bool? _asBoolOrNull(dynamic value) {
    if (value == null) return null;

    return _asBool(value);
  }

  static int? _asInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);

    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);

    return null;
  }
}
