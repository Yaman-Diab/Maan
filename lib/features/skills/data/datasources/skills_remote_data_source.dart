// -------------------------
// Skills Remote Data Source
// -------------------------

import 'package:dio/dio.dart';

import '../../../../core/media/certificate_file_picker_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/skill_type.dart';
import '../models/certificate_model.dart';
import '../models/skill_model.dart';

/// المكان الوحيد اللي بيعرف Dio وendpoints المهارات والشهادات.
abstract class SkillsRemoteDataSource {
  Future<List<Skill>> getSkills();

  Future<List<Certificate>> getCertificates();

  Future<void> addSkill({required String name, required SkillType type});

  Future<void> updateSkill({
    required int skillId,
    required String name,
    required SkillType type,
  });

  Future<void> deleteSkill(int skillId);

  Future<void> attachCertificate({
    required int skillId,
    required PickedCertificateFile file,
  });

  Future<void> replaceCertificate({
    required int certificateId,
    required PickedCertificateFile file,
  });
}

class SkillsRemoteDataSourceImpl implements SkillsRemoteDataSource {
  final ApiClient _apiClient;

  const SkillsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<Skill>> getSkills() async {
    final response = await _apiClient.request(
      endpoint: ApiEndpoints.skillsIndex,
      method: ApiMethod.get,
    );

    return SkillModel.listFromResponse(response);
  }

  @override
  Future<List<Certificate>> getCertificates() async {
    final response = await _apiClient.request(
      endpoint: ApiEndpoints.certificatesIndex,
      method: ApiMethod.get,
    );

    return CertificateModel.listFromResponse(response);
  }

  @override
  Future<void> addSkill({required String name, required SkillType type}) {
    return _apiClient.request(
      endpoint: ApiEndpoints.skillsStore,
      method: ApiMethod.post,
      data: {_nameField: name, _typeField: type.wireValue},
    );
  }

  @override
  Future<void> updateSkill({
    required int skillId,
    required String name,
    required SkillType type,
  }) {
    return _apiClient.request(
      endpoint: ApiEndpoints.skillsUpdate(skillId),
      method: ApiMethod.post,
      data: {_nameField: name, _typeField: type.wireValue},
    );
  }

  @override
  Future<void> deleteSkill(int skillId) {
    return _apiClient.request(
      endpoint: ApiEndpoints.skillsDelete(skillId),
      method: ApiMethod.delete,
    );
  }

  @override
  Future<void> attachCertificate({
    required int skillId,
    required PickedCertificateFile file,
  }) async {
    final formData = FormData.fromMap({_userSkillIdField: skillId});

    formData.files.add(
      MapEntry(
        _fileField,
        await MultipartFile.fromFile(file.path, filename: file.fileName),
      ),
    );

    await _apiClient.request(
      endpoint: ApiEndpoints.certificatesStore,
      method: ApiMethod.post,
      data: formData,
    );
  }

  @override
  Future<void> replaceCertificate({
    required int certificateId,
    required PickedCertificateFile file,
  }) async {
    final formData = FormData();

    formData.files.add(
      MapEntry(
        _fileField,
        await MultipartFile.fromFile(file.path, filename: file.fileName),
      ),
    );

    await _apiClient.request(
      endpoint: ApiEndpoints.certificatesUpdate(certificateId),
      method: ApiMethod.post,
      data: formData,
    );
  }

  static const String _nameField = 'name';
  static const String _typeField = 'type';
  static const String _userSkillIdField = 'user_skill_id';
  static const String _fileField = 'file_path';
}
