// -------------------------
// Project Donation Stats Model
// -------------------------

import '../../../../core/network/api_response_keys.dart';
import '../../domain/entities/project_donation_stats.dart';

/// قراءة `GET /api/project/{id}/donations/stats` — ✅ الشكل مؤكّد
/// بالكامل بمثال حقيقي.
///
/// ⚠️ **`donation_target`/`remaining_amount` بيرجعوا `null` عمداً** لو
/// المشروع بلا ميزانية محدّدة — بيتحفظوا `null` كما هم (لا يتحوّلوا
/// لصفر) لأن «بلا هدف» حالة مختلفة عن «هدف صفر»، والواجهة بتفرّق
/// بينهم عبر `ProjectDonationStats.hasTarget`.
class ProjectDonationStatsModel {
  final ProjectDonationStats entity;

  const ProjectDonationStatsModel(this.entity);

  factory ProjectDonationStatsModel.fromResponse(dynamic response) {
    final data = _asMap(
      response is Map
          ? Map<String, dynamic>.from(response)[ApiResponseKeys.data]
          : null,
    );

    if (data == null) {
      throw const FormatException('Donation stats response is missing "data".');
    }

    return ProjectDonationStatsModel(
      ProjectDonationStats(
        totalDonated: _asNum(data['total_donated']) ?? 0,
        donationTarget: _asNum(data['donation_target']),
        remainingAmount: _asNum(data['remaining_amount']),
        donationPercentage: _asNum(data['donation_percentage'])?.round() ?? 0,
        numberOfDonors: _asNum(data['number_of_donors'])?.toInt() ?? 0,
      ),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);

    return null;
  }

  /// Laravel بيرجّع المبالغ كنص عشري أحياناً (`"650000.00"`) — نفس
  /// ملاحظة `credibility_score` بالملف الشخصي.
  static num? _asNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);

    return null;
  }
}
