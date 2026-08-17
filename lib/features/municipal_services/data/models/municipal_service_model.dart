// -------------------------
// Municipal Service Model
// -------------------------

import '../../../../core/network/api_response_keys.dart';
import '../../domain/entities/municipal_service.dart';

/// قراءة عنصر خدمة من `GET /api/admin/services` — مثال استجابة حقيقي
/// كامل (أربع خدمات بكل حقولها) موجود بـCLAUDE.md.
///
/// `id`/`name`/`estimated_time_minutes` إلزامية — بلا وقت مقدّر
/// الشاشة كلها بلا معنى. `people_waiting`/`status` دفاعية بقيم
/// افتراضية آمنة (0 منتظر، غير نشطة) بدل ما تفشّل العنصر كامل.
class MunicipalServiceModel {
  final MunicipalService entity;

  const MunicipalServiceModel(this.entity);

  factory MunicipalServiceModel.fromMap(Map<String, dynamic> json) {
    final id = json[_Keys.id];
    final name = json[_Keys.name] as String?;
    final estimatedTimeMinutes = _asInt(json[_Keys.estimatedTimeMinutes]);

    if (id is! int || name == null || estimatedTimeMinutes == null) {
      throw const FormatException(
        'Municipal service data is missing required fields.',
      );
    }

    return MunicipalServiceModel(
      MunicipalService(
        id: id,
        name: name,
        estimatedTimeMinutes: estimatedTimeMinutes,
        peopleWaiting: _asInt(json[_Keys.peopleWaiting]) ?? 0,
        isActive: json[_Keys.status] == _Keys.activeStatus,
      ),
    );
  }

  static List<MunicipalService> listFromResponse(dynamic response) {
    final result = <MunicipalService>[];

    for (final item in _extractList(response)) {
      if (item is! Map) continue;

      try {
        result.add(
          MunicipalServiceModel.fromMap(Map<String, dynamic>.from(item)).entity,
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

  static int? _asInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);

    return null;
  }
}

abstract final class _Keys {
  static const String id = 'id';
  static const String name = 'name';
  static const String estimatedTimeMinutes = 'estimated_time_minutes';
  static const String peopleWaiting = 'people_waiting';
  static const String status = 'status';
  static const String activeStatus = 'active';
}
