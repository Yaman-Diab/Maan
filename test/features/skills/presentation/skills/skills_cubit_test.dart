import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/usecase/usecase.dart';
import 'package:maan/features/skills/domain/entities/certificate.dart';
import 'package:maan/features/skills/domain/entities/certificate_status.dart';
import 'package:maan/features/skills/domain/entities/skill.dart';
import 'package:maan/features/skills/domain/entities/skill_type.dart';
import 'package:maan/features/skills/domain/usecases/get_skills_usecase.dart';
import 'package:maan/features/skills/presentation/skills/cubit/skills_cubit.dart';
import 'package:maan/features/skills/presentation/skills/cubit/skills_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetSkills extends Mock implements GetSkillsUseCase {}

Skill _skill({int id = 1, Certificate? certificate}) {
  return Skill(
    id: id,
    name: 'مهارة $id',
    type: SkillType.technical,
    certificate: certificate,
  );
}

void main() {
  late _MockGetSkills getSkills;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getSkills = _MockGetSkills();
  });

  SkillsCubit build() => SkillsCubit(getSkills);

  group('load', () {
    blocTest<SkillsCubit, SkillsState>(
      'ناجح بقائمة غير فاضية → ready',
      setUp: () =>
          when(() => getSkills(any())).thenAnswer((_) async => Ok([_skill()])),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        predicate<SkillsState>((s) => s.status == SkillsStatus.loading),
        predicate<SkillsState>(
          (s) => s.status == SkillsStatus.ready && s.skills.length == 1,
        ),
      ],
    );

    blocTest<SkillsCubit, SkillsState>(
      'قائمة فاضية → empty',
      setUp: () =>
          when(() => getSkills(any())).thenAnswer((_) async => const Ok([])),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        predicate<SkillsState>((s) => s.status == SkillsStatus.loading),
        predicate<SkillsState>((s) => s.status == SkillsStatus.empty),
      ],
    );

    blocTest<SkillsCubit, SkillsState>(
      'فشل الطلب → error برسالة الفشل',
      setUp: () => when(
        () => getSkills(any()),
      ).thenAnswer((_) async => const Err(NetworkFailure('error_connection'))),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        predicate<SkillsState>((s) => s.status == SkillsStatus.loading),
        predicate<SkillsState>(
          (s) =>
              s.status == SkillsStatus.error &&
              s.errorMessage == 'error_connection',
        ),
      ],
    );
  });

  group('الإحصائيات المشتقّة من الحالة', () {
    blocTest<SkillsCubit, SkillsState>(
      'approved/pending/noCertificate بيتحسبوا صح من قائمة مختلطة',
      setUp: () => when(() => getSkills(any())).thenAnswer(
        (_) async => Ok([
          _skill(
            id: 1,
            certificate: const Certificate(
              id: 1,
              skillId: 1,
              status: CertificateStatus.approved,
            ),
          ),
          _skill(
            id: 2,
            certificate: const Certificate(
              id: 2,
              skillId: 2,
              status: CertificateStatus.pending,
            ),
          ),
          _skill(id: 3),
        ]),
      ),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.approvedCount, 1);
        expect(cubit.state.pendingCount, 1);
        expect(cubit.state.noCertificateCount, 1);
        expect(cubit.state.hasPendingCertificate, isTrue);
      },
    );
  });
}
