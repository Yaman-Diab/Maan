import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/media/picked_image.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/features/verification/domain/entities/verification_request.dart';
import 'package:maan/features/verification/domain/entities/verification_request_status.dart';
import 'package:maan/features/verification/domain/repositories/verification_repository.dart';
import 'package:maan/features/verification/domain/usecases/submit_verification_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockVerificationRepository extends Mock
    implements VerificationRepository {}

final _images = [
  PickedImage(
    path: '/tmp/a.jpg',
    bytes: Uint8List.fromList([1]),
    fileName: 'a.jpg',
  ),
  PickedImage(
    path: '/tmp/b.jpg',
    bytes: Uint8List.fromList([2]),
    fileName: 'b.jpg',
  ),
];

final _request = VerificationRequest(
  id: 1,
  userId: 1,
  nationalId: '12345678901',
  status: VerificationRequestStatus.pending,
  images: const [],
  createdAt: DateTime(2026, 8, 2),
  updatedAt: DateTime(2026, 8, 2),
);

void main() {
  late _MockVerificationRepository repository;
  late SubmitVerificationUseCase useCase;

  setUp(() {
    repository = _MockVerificationRepository();
    useCase = SubmitVerificationUseCase(repository);
  });

  test('بتمرّر الرقم الوطني والصور لحالها للـ repository', () async {
    when(
      () => repository.submit(
        nationalId: any(named: 'nationalId'),
        images: any(named: 'images'),
      ),
    ).thenAnswer((_) async => Ok(_request));

    final result = await useCase(
      SubmitVerificationParams(nationalId: '12345678901', images: _images),
    );

    expect(result, isA<Ok>());
    verify(
      () => repository.submit(nationalId: '12345678901', images: _images),
    ).called(1);
  });

  test('فشل الـ repository بيمرّ كما هو', () async {
    when(
      () => repository.submit(
        nationalId: any(named: 'nationalId'),
        images: any(named: 'images'),
      ),
    ).thenAnswer(
      (_) async => const Err(
        ValidationFailure(
          'error_validation_generic',
          fieldErrors: {
            'images': ['The images field is required.'],
          },
        ),
      ),
    );

    final result = await useCase(
      SubmitVerificationParams(nationalId: '12345678901', images: const []),
    );

    expect(result, isA<Err>());
  });
}
