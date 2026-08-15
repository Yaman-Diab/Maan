// -------------------------
// Complaints Remote Data Source
// -------------------------

import 'package:dio/dio.dart';

import '../../../../core/media/picked_complaint_media.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/entities/complaint_category.dart';
import '../../domain/entities/complaint_report_reason.dart';
import '../../domain/entities/complaint_sort.dart';
import '../../domain/entities/complaint_type.dart';
import '../models/complaint_model.dart';

/// المكان الوحيد اللي بيعرف Dio وendpoints الشكاوى.
abstract class ComplaintsRemoteDataSource {
  Future<List<Complaint>> getPublished({
    ComplaintType? type,
    ComplaintCategory? category,
    required ComplaintSort sort,
    required int page,
    required int pageSize,
  });

  Future<List<Complaint>> getMine({required int page, required int pageSize});

  Future<void> submit({
    required ComplaintType type,
    required ComplaintCategory category,
    required String title,
    String? description,
    required double latitude,
    required double longitude,
    List<PickedComplaintMedia> media,
  });

  Future<void> vote(int complaintId);

  Future<void> unvote(int complaintId);

  Future<void> report({
    required int complaintId,
    required ComplaintReportReason reason,
    required String description,
  });
}

class ComplaintsRemoteDataSourceImpl implements ComplaintsRemoteDataSource {
  final ApiClient _apiClient;

  const ComplaintsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<Complaint>> getPublished({
    ComplaintType? type,
    ComplaintCategory? category,
    required ComplaintSort sort,
    required int page,
    required int pageSize,
  }) async {
    final response = await _apiClient.request(
      endpoint: ApiEndpoints.complaintsPublished,
      method: ApiMethod.get,
      queryParameters: {
        if (type != null) 'type': type.wireValue,
        if (category != null) 'category_id': category.id,
        'sort': sort.wireValue,
        'page': page,
        'page_size': pageSize,
      },
    );

    return ComplaintModel.listFromResponse(response);
  }

  @override
  Future<List<Complaint>> getMine({
    required int page,
    required int pageSize,
  }) async {
    final response = await _apiClient.request(
      endpoint: ApiEndpoints.complaintsMine,
      method: ApiMethod.get,
      queryParameters: {'page': page, 'page_size': pageSize},
    );

    return ComplaintModel.listFromResponse(response, isMine: true);
  }

  @override
  Future<void> submit({
    required ComplaintType type,
    required ComplaintCategory category,
    required String title,
    String? description,
    required double latitude,
    required double longitude,
    List<PickedComplaintMedia> media = const [],
  }) async {
    final formData = FormData.fromMap({
      _typeField: type.wireValue,
      _categoryField: category.id,
      _titleField: title,
      if (description != null && description.isNotEmpty) _descriptionField: description,
      _latitudeField: latitude,
      _longitudeField: longitude,
    });

    // نفس سبب `images[]` بميزة التوثيق: اسم الحقل لازم ينتهي بـ`[]`
    // صراحة حتى يجمعهم Laravel كمصفوفة.
    for (final item in media) {
      formData.files.add(
        MapEntry(_mediaField, await MultipartFile.fromFile(item.path, filename: item.fileName)),
      );
    }

    await _apiClient.request(
      endpoint: ApiEndpoints.complaintsStore,
      method: ApiMethod.post,
      data: formData,
    );
  }

  @override
  Future<void> vote(int complaintId) {
    return _apiClient.request(
      endpoint: ApiEndpoints.complaintsVote,
      method: ApiMethod.post,
      data: {_idField: complaintId},
    );
  }

  @override
  Future<void> unvote(int complaintId) {
    return _apiClient.request(
      endpoint: ApiEndpoints.complaintsVote,
      method: ApiMethod.delete,
      data: {_idField: complaintId},
    );
  }

  @override
  Future<void> report({
    required int complaintId,
    required ComplaintReportReason reason,
    required String description,
  }) {
    return _apiClient.request(
      endpoint: ApiEndpoints.reportsStore,
      method: ApiMethod.post,
      data: {
        _reportComplaintIdField: complaintId,
        _reportTypeIdField: reason.typeId,
        _descriptionField: description,
      },
    );
  }

  static const String _typeField = 'type';
  static const String _categoryField = 'category_id';
  static const String _titleField = 'title';
  static const String _descriptionField = 'description';
  static const String _latitudeField = 'latitude';
  static const String _longitudeField = 'longitude';
  static const String _mediaField = 'media[]';
  static const String _idField = 'id';
  static const String _reportComplaintIdField = 'complain_id';
  static const String _reportTypeIdField = 'type_id';
}
