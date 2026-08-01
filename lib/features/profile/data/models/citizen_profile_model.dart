// -------------------------
// Citizen Profile Model
// -------------------------

import '../../../auth/data/models/auth_user_model.dart';
import '../../domain/entities/citizen_profile.dart';
import '../../domain/entities/profile_stats.dart';

/// قراءة استجابة `GET /api/profile`.
///
/// **المظروف مش مثبّت**: الباك اند بيرجّع الجسم أحياناً مسطّحاً وأحياناً
/// تحت `data`، وتعليق `AuthUserModel` بيتوقّعه تحت `data.user`. بدل ما
/// نراهن على شكل واحد، [fromMap] بتنزل بالتعشيش خطوة خطوة وبتقبل
/// الثلاثة. أرخص من انهيار الشاشة لأن الباك اند غيّر مستوى تعشيش.
class CitizenProfileModel {
  final AuthUserModel user;
  final ProfileStats stats;

  const CitizenProfileModel({required this.user, required this.stats});

  factory CitizenProfileModel.fromMap(Map<String, dynamic> json) {
    final container = _asMap(json[_Keys.data]) ?? json;
    final userMap = _asMap(container[_Keys.user]) ?? container;

    return CitizenProfileModel(
      user: AuthUserModel.fromMap(userMap),
      // المؤشرات ممكن تجي جنب المستخدم أو جوّاه — منجرّب الاثنين.
      stats: _statsFrom(container, userMap),
    );
  }

  CitizenProfile toEntity() {
    return CitizenProfile(user: user.toEntity(), stats: stats);
  }

  // -------------------------
  // Stats
  // -------------------------

  /// ⚠️ الأسماء هون **تخمين موثّق**، مش عقد. ما في endpoint بـ
  /// `collection.md` بيرجّع مؤشرات، فأي مفتاح ما بينوجد بيضل `null`
  /// والواجهة بتعرض «—». يوم يثبّت الباك اند أسماءه، التعديل هون فقط.
  static ProfileStats _statsFrom(
    Map<String, dynamic> container,
    Map<String, dynamic> userMap,
  ) {
    int? read(String key) {
      final value = container[key] ?? userMap[key];

      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);

      return null;
    }

    int? readPercentage(String key) {
      final value = read(key);
      if (value == null) return null;

      // القصّ حماية من قيمة خارج المدى بتكسر شريط التقدّم.
      return value.clamp(0, 100);
    }

    return ProfileStats(
      citizenshipIndex: readPercentage(_Keys.citizenshipIndex),
      authenticationIndex: readPercentage(_Keys.authenticationIndex),
      volunteeringCount: read(_Keys.volunteeringCount),
      contributionsCount: read(_Keys.contributionsCount),
      licensesCount: read(_Keys.licensesCount),
    );
  }

  // -------------------------
  // Helpers
  // -------------------------

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);

    return null;
  }
}

abstract final class _Keys {
  static const String data = 'data';
  static const String user = 'user';

  static const String citizenshipIndex = 'citizenship_index';
  static const String authenticationIndex = 'authentication_index';
  static const String volunteeringCount = 'volunteering_count';
  static const String contributionsCount = 'contributions_count';
  static const String licensesCount = 'licenses_count';
}
