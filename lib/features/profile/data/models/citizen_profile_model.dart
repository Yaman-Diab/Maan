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
    final rawUserMap = _asMap(container[_Keys.user]) ?? container;

    // ⚠️ **الصورة براجعة بمستوى الملف الشخصي (`data.image`) لا جوّا
    // `user`** — مؤكّد بمثال استجابة حقيقي لـ`GET /api/profile`. بلا
    // هالدمج `AuthUserModel.fromMap` ما رح يلاقي الصورة أبداً لأنها مش
    // بنفس الخريطة يلي بيفحصها (كانت هيك دايماً `null` رغم وجودها
    // فعلياً عند السيرفر).
    final userMap = {
      ...rawUserMap,
      if (rawUserMap[_Keys.image] == null && container[_Keys.image] != null)
        _Keys.image: container[_Keys.image],
    };

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

  /// ✅ **الكل مؤكّد** بمثال استجابة حقيقي لـ`GET /api/profile` —
  /// `citizenship_score`/`credibility_score` (الثاني بيرجع كنص عشري
  /// `"50.00"` لا رقم، فـ`read` بتجرّب `double.tryParse` بعد فشل
  /// `int.tryParse`)، و`volunteering_count`/`donation_count` (عدّادات
  /// صحيحة)، و`total_donated` (مبلغ فبيقرأه `readAmount` بلا تقريب —
  /// نفس نمط `ProjectDonationStatsModel._asNum`). حقل «التراخيص»
  /// السابق (`licenses_count`) انحذف — بلا عقد ولا طلب عرض.
  static ProfileStats _statsFrom(
    Map<String, dynamic> container,
    Map<String, dynamic> userMap,
  ) {
    int? read(String key) {
      final value = container[key] ?? userMap[key];

      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? double.tryParse(value)?.round();
      }

      return null;
    }

    int? readPercentage(String key) {
      final value = read(key);
      if (value == null) return null;

      // القصّ حماية من قيمة خارج المدى بتكسر شريط التقدّم.
      return value.clamp(0, 100);
    }

    num? readAmount(String key) {
      final value = container[key] ?? userMap[key];

      if (value is num) return value;
      if (value is String) return num.tryParse(value);

      return null;
    }

    return ProfileStats(
      citizenshipIndex: readPercentage(_Keys.citizenshipIndex),
      credibilityIndex: readPercentage(_Keys.credibilityIndex),
      volunteeringCount: read(_Keys.volunteeringCount),
      donationCount: read(_Keys.donationCount),
      totalDonated: readAmount(_Keys.totalDonated),
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
  static const String image = 'image';

  static const String citizenshipIndex = 'citizenship_score';
  static const String credibilityIndex = 'credibility_score';
  static const String volunteeringCount = 'volunteering_count';
  static const String donationCount = 'donation_count';
  static const String totalDonated = 'total_donated';
}
