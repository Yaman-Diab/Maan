import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/location/location_service.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/features/complaints/domain/entities/complaint_category.dart';
import 'package:maan/features/complaints/domain/entities/complaint_type.dart';
import 'package:maan/features/complaints/domain/usecases/submit_complaint_usecase.dart';
import 'package:maan/features/complaints/presentation/submit_complaint/cubit/submit_complaint_cubit.dart';
import 'package:maan/features/complaints/presentation/submit_complaint/cubit/submit_complaint_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSubmit extends Mock implements SubmitComplaintUseCase {}

class _MockLocation extends Mock implements LocationService {}

void main() {
  late _MockSubmit submit;
  late _MockLocation location;

  setUpAll(() {
    registerFallbackValue(
      const SubmitComplaintParams(
        type: ComplaintType.individual,
        category: ComplaintCategory.other,
        title: '',
        latitude: 0,
        longitude: 0,
      ),
    );
  });

  setUp(() {
    submit = _MockSubmit();
    location = _MockLocation();
  });

  SubmitComplaintCubit build() => SubmitComplaintCubit(submit, location);

  group('canSubmit', () {
    test('فردية بلا وصف/تصنيف/موقع → false', () {
      const state = SubmitComplaintState();
      expect(state.canSubmit, isFalse);
    });

    test('فردية مكتملة بلا وصف → false (الوصف إلزامي)', () {
      final state = const SubmitComplaintState().copyWith(
        category: ComplaintCategory.roads,
        title: 'عنوان',
        latitude: 1,
        longitude: 1,
      );
      expect(state.canSubmit, isFalse);
    });

    test('فردية مكتملة بوصف → true', () {
      final state = const SubmitComplaintState().copyWith(
        category: ComplaintCategory.roads,
        title: 'عنوان',
        description: 'وصف',
        latitude: 1,
        longitude: 1,
      );
      expect(state.canSubmit, isTrue);
    });

    test('طارئة بلا وصف بس بموقع وتصنيف وعنوان → true (الوصف اختياري)', () {
      final state = const SubmitComplaintState().copyWith(
        type: ComplaintType.emergency,
        category: ComplaintCategory.roads,
        title: 'عنوان',
        latitude: 1,
        longitude: 1,
      );
      expect(state.canSubmit, isTrue);
    });
  });

  group('useCurrentLocation', () {
    blocTest<SubmitComplaintCubit, SubmitComplaintState>(
      'نجح → latitude/longitude بتتحدّث',
      setUp: () => when(() => location.getCurrentLocation()).thenAnswer(
        (_) async => const LocationResult(latitude: 33.5, longitude: 36.2),
      ),
      build: build,
      act: (cubit) => cubit.useCurrentLocation(),
      expect: () => [
        predicate<SubmitComplaintState>((s) => s.isLocating == true),
        predicate<SubmitComplaintState>(
          (s) => s.isLocating == false && s.latitude == 33.5 && s.longitude == 36.2,
        ),
      ],
    );

    blocTest<SubmitComplaintCubit, SubmitComplaintState>(
      'خدمة الموقع مطفية → رسالة خطأ بلا إحداثيات',
      setUp: () => when(() => location.getCurrentLocation()).thenThrow(
        const LocationServiceException(LocationFailureReason.serviceDisabled),
      ),
      build: build,
      act: (cubit) => cubit.useCurrentLocation(),
      expect: () => [
        predicate<SubmitComplaintState>((s) => s.isLocating == true),
        predicate<SubmitComplaintState>(
          (s) =>
              s.isLocating == false &&
              !s.hasLocation &&
              s.locationErrorMessage != null,
        ),
      ],
    );
  });

  group('submit', () {
    blocTest<SubmitComplaintCubit, SubmitComplaintState>(
      'canSubmit=false → ما بيصير طلب شبكة أصلاً',
      build: build,
      act: (cubit) => cubit.submit(),
      expect: () => [],
      verify: (_) => verifyNever(() => submit(any())),
    );

    blocTest<SubmitComplaintCubit, SubmitComplaintState>(
      'ناجح → submitted true',
      seed: () => const SubmitComplaintState().copyWith(
        category: ComplaintCategory.roads,
        title: 'عنوان',
        description: 'وصف',
        latitude: 1,
        longitude: 1,
      ),
      setUp: () => when(() => submit(any())).thenAnswer((_) async => const Ok(null)),
      build: build,
      act: (cubit) => cubit.submit(),
      expect: () => [
        predicate<SubmitComplaintState>((s) => s.isSubmitting == true),
        predicate<SubmitComplaintState>(
          (s) => s.isSubmitting == false && s.submitted == true,
        ),
      ],
    );

    blocTest<SubmitComplaintCubit, SubmitComplaintState>(
      'فشل → errorMessage بلا submitted',
      seed: () => const SubmitComplaintState().copyWith(
        category: ComplaintCategory.roads,
        title: 'عنوان',
        description: 'وصف',
        latitude: 1,
        longitude: 1,
      ),
      setUp: () => when(() => submit(any())).thenAnswer(
        (_) async => const Err(NetworkFailure('error_connection')),
      ),
      build: build,
      act: (cubit) => cubit.submit(),
      expect: () => [
        predicate<SubmitComplaintState>((s) => s.isSubmitting == true),
        predicate<SubmitComplaintState>(
          (s) =>
              s.isSubmitting == false &&
              s.submitted == false &&
              s.errorMessage == 'error_connection',
        ),
      ],
    );
  });
}
