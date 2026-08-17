// -------------------------
// Certificate
// -------------------------

import 'package:equatable/equatable.dart';

import 'certificate_rejection_reason.dart';
import 'certificate_status.dart';

/// شهادة إثبات مرفقة بمهارة — `GET /api/certificate` بترجّع قائمة
/// شهادات المستخدم، كل وحدة مرتبطة بمهارة عبر `user_skill_id`.
final class Certificate extends Equatable {
  final int id;
  final int skillId;
  final CertificateStatus status;
  final String? fileName;

  /// `null` إلا لو [status] كانت [CertificateStatus.rejected].
  final CertificateRejectionReason? rejectionReason;

  const Certificate({
    required this.id,
    required this.skillId,
    required this.status,
    this.fileName,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [id, skillId, status, fileName, rejectionReason];
}
