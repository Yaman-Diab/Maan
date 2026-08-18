// -------------------------
// Project Vote Receipt Model
// -------------------------

import '../../../../core/network/api_response_keys.dart';
import '../../domain/entities/project_vote_receipt.dart';

/// قراءة استجابة `POST /api/project/vote/{id}` — ✅ الشكل مؤكّد
/// بالكامل بمثال حقيقي (`201`، `data.project_id`/`value`/`vote_weight`/
/// `citizenship_score_at_vote_time`).
class ProjectVoteReceiptModel {
  final ProjectVoteReceipt entity;

  const ProjectVoteReceiptModel(this.entity);

  factory ProjectVoteReceiptModel.fromResponse(dynamic response) {
    final data = _asMap(
      response is Map
          ? Map<String, dynamic>.from(response)[ApiResponseKeys.data]
          : null,
    );

    if (data == null) {
      throw const FormatException('Vote response is missing "data".');
    }

    final projectId = _asInt(data['project_id']);
    final value = data['value'];

    if (projectId == null || value is! bool) {
      throw const FormatException('Vote response is missing required fields.');
    }

    return ProjectVoteReceiptModel(
      ProjectVoteReceipt(
        projectId: projectId,
        value: value,
        voteWeight: _asDouble(data['vote_weight']) ?? 0,
        citizenshipScoreAtVoteTime:
            _asDouble(data['citizenship_score_at_vote_time']) ?? 0,
      ),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);

    return null;
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
