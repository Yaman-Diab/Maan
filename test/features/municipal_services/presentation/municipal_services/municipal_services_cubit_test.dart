import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/usecase/usecase.dart';
import 'package:maan/features/municipal_services/domain/entities/municipal_service.dart';
import 'package:maan/features/municipal_services/domain/usecases/get_municipal_services_usecase.dart';
import 'package:maan/features/municipal_services/presentation/municipal_services/cubit/municipal_services_cubit.dart';
import 'package:maan/features/municipal_services/presentation/municipal_services/cubit/municipal_services_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetServices extends Mock implements GetMunicipalServicesUseCase {}

MunicipalService _service({int id = 1, bool isActive = true}) {
  return MunicipalService(
    id: id,
    name: 'خدمة $id',
    estimatedTimeMinutes: 10,
    isActive: isActive,
  );
}

void main() {
  late _MockGetServices getServices;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getServices = _MockGetServices();
  });

  MunicipalServicesCubit build() => MunicipalServicesCubit(getServices);

  group('load', () {
    blocTest<MunicipalServicesCubit, MunicipalServicesState>(
      'ناجح بقائمة غير فاضية → ready',
      setUp: () => when(
        () => getServices(any()),
      ).thenAnswer((_) async => Ok([_service()])),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        predicate<MunicipalServicesState>(
          (s) => s.status == MunicipalServicesStatus.loading,
        ),
        predicate<MunicipalServicesState>(
          (s) =>
              s.status == MunicipalServicesStatus.ready &&
              s.services.length == 1,
        ),
      ],
    );

    blocTest<MunicipalServicesCubit, MunicipalServicesState>(
      'قائمة فاضية → empty',
      setUp: () =>
          when(() => getServices(any())).thenAnswer((_) async => const Ok([])),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        predicate<MunicipalServicesState>(
          (s) => s.status == MunicipalServicesStatus.loading,
        ),
        predicate<MunicipalServicesState>(
          (s) => s.status == MunicipalServicesStatus.empty,
        ),
      ],
    );

    blocTest<MunicipalServicesCubit, MunicipalServicesState>(
      'فشل الطلب → error برسالة الفشل',
      setUp: () => when(
        () => getServices(any()),
      ).thenAnswer((_) async => const Err(NetworkFailure('error_connection'))),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        predicate<MunicipalServicesState>(
          (s) => s.status == MunicipalServicesStatus.loading,
        ),
        predicate<MunicipalServicesState>(
          (s) =>
              s.status == MunicipalServicesStatus.error &&
              s.errorMessage == 'error_connection',
        ),
      ],
    );
  });
}
