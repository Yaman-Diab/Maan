import 'package:flutter_test/flutter_test.dart';
import 'package:maan/features/verification/data/models/verification_request_model.dart';
import 'package:maan/features/verification/domain/entities/verification_request_status.dart';

Map<String, dynamic> _realResponse() {
  return {
    'status': 1,
    'message': 'your request has been submitted',
    'data': {
      'user_id': 1,
      'national_id': '12345678901',
      'status': 'pending',
      'updated_at': '2026-08-02T08:38:45.000000Z',
      'created_at': '2026-08-02T08:38:45.000000Z',
      'id': 1,
      'images': [
        {
          'id': 1,
          'verification_request_id': 1,
          'image_url': 'http://localhost/storage/uploads/a.png',
          'created_at': '2026-08-02T08:38:45.000000Z',
          'updated_at': '2026-08-02T08:38:45.000000Z',
          'deleted_at': null,
        },
      ],
    },
  };
}

void main() {
  group('VerificationRequestModel.fromMap', () {
    test('بتقرأ من تحت data', () {
      final model = VerificationRequestModel.fromMap(_realResponse());

      expect(model.id, 1);
      expect(model.userId, 1);
      expect(model.nationalId, '12345678901');
      expect(model.status, VerificationRequestStatus.pending);
      expect(model.images, hasLength(1));
      expect(model.images.single.imageUrl, 'http://localhost/storage/uploads/a.png');
    });

    test('بتقرأ الجذر مباشرة لو ما في data', () {
      final data = _realResponse()['data'] as Map<String, dynamic>;

      final model = VerificationRequestModel.fromMap(data);

      expect(model.id, 1);
      expect(model.nationalId, '12345678901');
    });

    test('بلا id بترمي', () {
      final data = Map<String, dynamic>.from(
        _realResponse()['data'] as Map<String, dynamic>,
      )..remove('id');

      expect(
        () => VerificationRequestModel.fromMap({'data': data}),
        throwsFormatException,
      );
    });

    test('بلا صور بترجع لستة فاضية لا ترمي', () {
      final data = Map<String, dynamic>.from(
        _realResponse()['data'] as Map<String, dynamic>,
      )..remove('images');

      final model = VerificationRequestModel.fromMap({'data': data});

      expect(model.images, isEmpty);
    });

    test('toEntity بتحافظ على القيم', () {
      final entity = VerificationRequestModel.fromMap(_realResponse()).toEntity();

      expect(entity.id, 1);
      expect(entity.status, VerificationRequestStatus.pending);
      expect(entity.images.single.id, 1);
    });
  });

  group('VerificationRequestStatus.fromApi', () {
    test('pending هي القيمة المؤكّدة الوحيدة', () {
      expect(
        VerificationRequestStatus.fromApi('pending'),
        VerificationRequestStatus.pending,
      );
    });

    test('حالات النتيجة بتنقرأ مع مرادفاتها الشائعة', () {
      // ⚠️ القيم النصّية **مخمَّنة**: وجود الحالتين مؤكّد من endpoints
      // الأدمن (approve/reject) بس أسماءها وقت القراءة لا — لهيك
      // بنقبل أكتر من مرادف. راجع تعليق `VerificationRequestStatus`.
      for (final value in ['approved', 'accepted', 'verified']) {
        expect(
          VerificationRequestStatus.fromApi(value),
          VerificationRequestStatus.approved,
          reason: value,
        );
      }

      for (final value in ['rejected', 'refused', 'declined']) {
        expect(
          VerificationRequestStatus.fromApi(value),
          VerificationRequestStatus.rejected,
          reason: value,
        );
      }
    });

    test('بتتجاهل حالة الأحرف والمسافات الزائدة', () {
      expect(
        VerificationRequestStatus.fromApi('  PENDING '),
        VerificationRequestStatus.pending,
      );
    });

    test('أي قيمة تانية بترجع unknown بدل ما ترمي', () {
      expect(
        VerificationRequestStatus.fromApi('escalated'),
        VerificationRequestStatus.unknown,
      );
      expect(
        VerificationRequestStatus.fromApi(''),
        VerificationRequestStatus.unknown,
      );
      expect(
        VerificationRequestStatus.fromApi(null),
        VerificationRequestStatus.unknown,
      );
    });
  });
}
