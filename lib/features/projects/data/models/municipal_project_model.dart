// -------------------------
// Municipal Project Model
// -------------------------

import '../../../../core/network/api_media.dart';
import '../../../../core/network/api_response_keys.dart';
import '../../domain/entities/municipal_project.dart';
import '../../domain/entities/project_reaction.dart';
import '../../domain/entities/project_requirement.dart';

/// قراءة عنصر مشروع — من مسارين مختلفين بشكلين متكامِلين، مدموجَين
/// بطبقة data (`ProjectsRepositoryImpl.getProjects`) بعد التحليل.
///
/// ✅ **`GET /api/project/votable` مؤكّد بالكامل بمثال حقيقي** — بس
/// بلا `image`/`location`/`is_voluntary`/`is_donation` (غياب قاطع،
/// مؤكّد من كود الباك اند نفسه: `ProjectVoteService::listVotable()`
/// بيبني مصفوفة استجابة يدوية بـ13 مفتاح بالضبط).
///
/// ✅ **`GET /api/project/{id}` (`show`) مؤكّد كمان من كود الباك اند**
/// (`ProjectService::formatProject`) — هو مصدر `image`/`location`/
/// `is_voluntary`/`is_donation`/`total_required_volunteers`. بلا حقول
/// التصويت (تلك من `votable` بس). أسماء الحقول هون (`is_voluntary`،
/// `is_donation`، `total_required_volunteers`) بتتقرأ **أولاً** —
/// مؤكّدة حرفياً من السورس، مش تخمين. الأسماء القديمة
/// (`requires_volunteers`/`requires_donations`/`volunteers_needed`)
/// ضلّت كخط دفاع احتياطي بس، لو تغيّر الشكل مستقبلاً.
///
/// ⚠️ **باگ حقيقي انصلح: `my_vote` كائن لا `bool`** — الشكل الحقيقي
/// `"my_vote": {"id":..,"value":true,"vote_weight":"11.0000",...}` أو
/// `null`، لا `true`/`false` مباشرة كما افترضنا قبل التأكيد. القراءة
/// القديمة (`_asBoolOrNull` على القيمة الخام) كانت بتمرّر كائناً لدالة
/// بتتوقّع bool، وبما إنه مش bool/num/String كانت `_asBool` ترجع
/// `false` افتراضياً — يعني أي مستخدم صوّت "أحبذ" (`value:true`) كان
/// رح يبيّن له الزر المعاكس "لا أحبذ" مفعّل. الإصلاح: نقرأ
/// `my_vote['value']` تحديداً، لا `my_vote` نفسه.
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
    final requiresVolunteers = _asBool(
      json['is_voluntary'] ?? json['requires_volunteers'],
    );
    final needed = _asInt(
      json['total_required_volunteers'] ??
          json['volunteers_needed'] ??
          json['required_volunteers'],
    );
    final approved = _asInt(json['total_approved_volunteers']);

    final myVote = _asMap(json['my_vote']);

    return MunicipalProjectModel(
      MunicipalProject(
        id: id,
        title: title,
        description: _firstString(json, const ['description', 'body']),
        imageUrl:
            ApiMedia.firstUrl(json['media'], onlyType: ApiMedia.imageType) ??
            _firstString(json, const [
              'image_url',
              'image',
              'file_url',
              'photo',
            ]),
        latitude: _asDouble(position?['latitude'] ?? json['latitude']),
        longitude: _asDouble(position?['longitude'] ?? json['longitude']),
        type: _firstString(json, const ['type']),
        status: _firstString(json, const ['status']),
        isVotable: _asBoolOrNull(json['is_votable']),
        budget: _asNum(json['budget']),
        requirements: _requirementsFrom(json['requirements']),
        votingStatus: _firstString(json, const ['voting_status']),
        votingEndsAt: _tryParseDate(json['voting_ends_at']),
        approvalPercentage: _asInt(json['approval_percentage']),
        requiresVolunteers: requiresVolunteers,
        // العدد بس لو المشروع فعلاً بده تطوع — بلاها ممكن يرجع رقم
        // قديم محفوظ من إعداد سابق فتظهر البطاقة كأنها بتطلب متطوعين.
        volunteersNeeded: requiresVolunteers ? needed : null,
        volunteersApproved: requiresVolunteers ? approved : null,
        requiresDonations: _asBool(
          json['is_donation'] ?? json['requires_donations'],
        ),
        totalVotes: _asInt(json['total_votes']) ?? 0,
        weightedYesVotes: _asDouble(json['weighted_yes_votes']) ?? 0,
        weightedOpposeVotes: _asDouble(json['weighted_no_votes']) ?? 0,
        myReaction: ProjectReaction.fromVoteFields(
          hasVoted: _asBool(json['has_voted']),
          myVote: myVote == null ? null : _asBoolOrNull(myVote['value']),
        ),
      ),
    );
  }

  /// قراءة `GET /api/project/{id}` (`show`) — بس الحقول يلي `votable`
  /// ما بيرجّعها، عشان `ProjectsRepositoryImpl` يدمجها على المشروع
  /// الموجود أصلاً بلا ما يفقد حقول التصويت.
  factory MunicipalProjectModel.detailFromResponse(dynamic response) {
    final data = _asMap(
      response is Map
          ? Map<String, dynamic>.from(response)[ApiResponseKeys.data]
          : null,
    );

    if (data == null) {
      throw const FormatException('Project detail response is missing "data".');
    }

    return MunicipalProjectModel.fromMap(data);
  }

  /// كل عنصر بيتجاهل بصمت لو `id`/`skill_name` ناقصين — دفاعي نفس نمط
  /// [listFromResponse]، بدل ما يفشل المشروع كامل بسبب متطلّب واحد
  /// مشوَّه.
  static List<ProjectRequirement> _requirementsFrom(dynamic value) {
    if (value is! List) return const [];

    final result = <ProjectRequirement>[];

    for (final item in value) {
      final map = _asMap(item);
      if (map == null) continue;

      final id = map['id'];
      final skillName = _firstString(map, const ['skill_name']);
      if (id is! int || skillName == null) continue;

      result.add(
        ProjectRequirement(
          id: id,
          skillName: skillName,
          skillType: _firstString(map, const ['skill_type']),
          requiredCount: _asInt(map['required_count']) ?? 0,
          isNeedCertificate: _asBool(map['is_need_certificate']),
          approvedCount: _asInt(map['approved_count']) ?? 0,
          remainingCount: _asInt(map['remaining_count']) ?? 0,
        ),
      );
    }

    return result;
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;

    return DateTime.tryParse(value);
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

  /// الباك اند بيرجّع المبالغ كنص عشري أحياناً — نفس ملاحظة
  /// `ProjectDonationStatsModel._asNum`.
  static num? _asNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);

    return null;
  }
}
