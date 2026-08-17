import 'package:flutter_test/flutter_test.dart';
import 'package:maan/features/skills/data/models/certificate_model.dart';
import 'package:maan/features/skills/domain/entities/certificate_rejection_reason.dart';
import 'package:maan/features/skills/domain/entities/certificate_status.dart';

void main() {
  group('fromMap — الحقول المؤكّدة من عقد الإرسال', () {
    test('يقرأ الحقول الأساسية صح', () {
      final model = CertificateModel.fromMap({
        'id': 5,
        'user_skill_id': 7,
        'status': 'approved',
      });

      expect(model.entity.id, 5);
      expect(model.entity.skillId, 7);
      expect(model.entity.status, CertificateStatus.approved);
    });

    test('id/user_skill_id ناقصة → FormatException', () {
      expect(
        () => CertificateModel.fromMap({'user_skill_id': 1}),
        throwsFormatException,
      );
      expect(() => CertificateModel.fromMap({'id': 1}), throwsFormatException);
    });

    test('حالة غير معروفة ما بترمي — بتترجم لـ unknown', () {
      final model = CertificateModel.fromMap({
        'id': 1,
        'user_skill_id': 1,
        'status': 'weird_status',
      });

      expect(model.entity.status, CertificateStatus.unknown);
    });

    test('rejectionReason بيتقرأ بس لو الحالة rejected', () {
      final rejected = CertificateModel.fromMap({
        'id': 1,
        'user_skill_id': 1,
        'status': 'rejected',
        'rejection_reason': 'blurry_image',
      });
      expect(
        rejected.entity.rejectionReason,
        CertificateRejectionReason.blurryImage,
      );

      final approved = CertificateModel.fromMap({
        'id': 1,
        'user_skill_id': 1,
        'status': 'approved',
        'rejection_reason': 'blurry_image',
      });
      expect(approved.entity.rejectionReason, isNull);
    });
  });

  group('اسم الملف — أول اسم موجود بيُستخدم، مع اقتطاع المسار', () {
    test('file_name أولاً، بعدين file_path، بعدين file', () {
      final a = CertificateModel.fromMap({
        'id': 1,
        'user_skill_id': 1,
        'file_name': 'شهادة.pdf',
      });
      expect(a.entity.fileName, 'شهادة.pdf');

      final b = CertificateModel.fromMap({
        'id': 1,
        'user_skill_id': 1,
        'file_path': '/storage/certificates/abc.pdf',
      });
      expect(b.entity.fileName, 'abc.pdf');

      final c = CertificateModel.fromMap({'id': 1, 'user_skill_id': 1});
      expect(c.entity.fileName, isNull);
    });
  });

  group('listFromResponse — أشكال تغليف مختلفة', () {
    test('قائمة مباشرة', () {
      final result = CertificateModel.listFromResponse([
        {'id': 1, 'user_skill_id': 1, 'status': 'pending'},
        {'id': 2, 'user_skill_id': 2, 'status': 'approved'},
      ]);

      expect(result.length, 2);
    });

    test('قائمة تحت data', () {
      final result = CertificateModel.listFromResponse({
        'data': [
          {'id': 1, 'user_skill_id': 1, 'status': 'pending'},
        ],
      });

      expect(result.length, 1);
    });

    test('عنصر غلط بينترمى بصمت بدل ما يوقّع القائمة كلها', () {
      final result = CertificateModel.listFromResponse([
        {'id': 1, 'user_skill_id': 1, 'status': 'pending'},
        {'status': 'pending'},
        {'id': 3, 'user_skill_id': 3, 'status': 'pending'},
      ]);

      expect(result.length, 2);
      expect(result.map((c) => c.id), [1, 3]);
    });
  });
}
