// -------------------------
// Upload Avatar Use Case
// -------------------------

import 'dart:typed_data';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/profile_repository.dart';

final class UploadAvatarParams {
  final Uint8List bytes;
  final String fileName;

  const UploadAvatarParams({required this.bytes, required this.fileName});
}

/// رفع الصورة الشخصية.
///
/// الاختيار والقص والضغط بتصير قبل هون (`ImagePickerService`) لأنها
/// خطوات منصّة لا منطق عمل. اللي بيوصل هون بايتات جاهزة للرفع.
class UploadAvatarUseCase implements UseCase<String?, UploadAvatarParams> {
  final ProfileRepository _repository;

  const UploadAvatarUseCase(this._repository);

  @override
  Future<Result<String?>> call(UploadAvatarParams params) {
    return _repository.uploadAvatar(
      bytes: params.bytes,
      fileName: params.fileName,
    );
  }
}
