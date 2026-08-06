import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/features/verification/domain/entities/verification_request.dart';
import 'package:maan/features/verification/domain/entities/verification_request_status.dart';
import 'package:maan/features/verification/domain/repositories/verification_repository.dart';
import 'package:maan/features/verification/domain/usecases/update_verification_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockVerificationRepository extends Mock
    implements VerificationRepository {}

final _request = VerificationRequest(
  id: 2,
  userId: 2,
  nationalId: '01234567892',
  status: VerificationRequestStatus.pending,
  images: const [],
  createdAt: DateTime(2026, 8, 2),
  updatedAt: DateTime(2026, 8, 2),
);

void main() {
  late _MockVerificationRepository repository;
  late UpdateVerificationUseCase useCase;

  setUp(() {
    repository = _MockVerificationRepository();
    useCase = UpdateVerificationUseCase(repository);
  });

  test('بتمرّر معرّف الطلب والرقم الوطني لحالهم للـ repository', () async {
    when(
      () => repository.update(
        requestId: any(named: 'requestId'),
        nationalId: any(named: 'nationalId'),
      ),
    ).thenAnswer((_) async => Ok(_request));

    final result = await useCase(
      const UpdateVerificationParams(requestId: 2, nationalId: '01234567892'),
    );

    expect(result, isA<Ok>());
    verify(
      () => repository.update(requestId: 2, nationalId: '01234567892'),
    ).called(1);
  });

  test('فشل الـ repository بيمرّ كما هو', () async {
    when(
      () => repository.update(
        requestId: any(named: 'requestId'),
        nationalId: any(named: 'nationalId'),
      ),
    ).thenAnswer(
      (_) async => const Err(ValidationFailure('error_validation_generic')),
    );

    final result = await useCase(
      const UpdateVerificationParams(requestId: 2, nationalId: '01234567892'),
    );

    expect(result, isA<Err>());
  });
}
