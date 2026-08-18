import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/features/projects/data/datasources/projects_remote_data_source.dart';
import 'package:maan/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:maan/features/projects/domain/entities/municipal_project.dart';
import 'package:maan/features/projects/domain/entities/project_donation_stats.dart';
import 'package:maan/features/projects/domain/entities/project_vote_receipt.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements ProjectsRemoteDataSource {}

const _donating = MunicipalProject(
  id: 1,
  title: 'مشروع بتبرعات',
  requiresDonations: true,
);

const _notDonating = MunicipalProject(id: 2, title: 'مشروع بلا تبرعات');

const _stats = ProjectDonationStats(
  totalDonated: 650000,
  donationTarget: 1000000,
  remainingAmount: 350000,
  donationPercentage: 65,
  numberOfDonors: 42,
);

void main() {
  late _MockRemote remote;
  late ProjectsRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = ProjectsRepositoryImpl(remote);

    when(() => remote.getDonationStats(any())).thenAnswer((_) async => _stats);
  });

  group('getProjects — دمج إحصائيات التبرعات', () {
    test('بتنجلب للمشاريع اللي بتقبل تبرعات وبتنضم للكيان', () async {
      when(() => remote.getProjects()).thenAnswer((_) async => [_donating]);

      final result = await repository.getProjects();

      final project = (result as Ok<List<MunicipalProject>>).value.single;
      expect(project.donationStats, _stats);
      verify(() => remote.getDonationStats(1)).called(1);
    });

    test(
      '⚠️ ما بتنطلب أصلاً للمشاريع اللي ما بتقبل تبرعات — توفير طلبات',
      () async {
        when(
          () => remote.getProjects(),
        ).thenAnswer((_) async => [_notDonating]);

        final result = await repository.getProjects();

        expect(
          (result as Ok<List<MunicipalProject>>).value.single.donationStats,
          isNull,
        );
        verifyNever(() => remote.getDonationStats(any()));
      },
    );

    test(
      '⚠️ فشل الإحصائيات ما بيكسر القائمة — المشروع بيوصل بلا شريط',
      () async {
        when(() => remote.getProjects()).thenAnswer((_) async => [_donating]);
        when(
          () => remote.getDonationStats(any()),
        ).thenThrow(Exception('stats endpoint down'));

        final result = await repository.getProjects();

        // الأهم: `Ok` لا `Err` — القائمة بتوصل كاملة.
        expect(result, isA<Ok<List<MunicipalProject>>>());
        expect(
          (result as Ok<List<MunicipalProject>>).value.single.donationStats,
          isNull,
        );
      },
    );

    test('فشل إحصائيات مشروع ما بيمنع نجاح غيره', () async {
      const other = MunicipalProject(
        id: 3,
        title: 'تاني',
        requiresDonations: true,
      );

      when(
        () => remote.getProjects(),
      ).thenAnswer((_) async => [_donating, other]);
      when(() => remote.getDonationStats(1)).thenThrow(Exception('down'));

      final result = await repository.getProjects();
      final projects = (result as Ok<List<MunicipalProject>>).value;

      expect(projects.firstWhere((p) => p.id == 1).donationStats, isNull);
      expect(projects.firstWhere((p) => p.id == 3).donationStats, _stats);
    });

    test('فشل جلب القائمة نفسها بيرجّع Err', () async {
      when(() => remote.getProjects()).thenThrow(Exception('boom'));

      final result = await repository.getProjects();

      expect(result, isA<Err>());
    });
  });

  group('التصويت', () {
    setUp(() {
      registerFallbackValue(0);
    });

    test('vote بترجّع الإيصال', () async {
      const receipt = ProjectVoteReceipt(
        projectId: 1,
        value: true,
        voteWeight: 7.32,
        citizenshipScoreAtVoteTime: 40,
      );
      when(
        () => remote.vote(projectId: 1, value: true),
      ).thenAnswer((_) async => receipt);

      final result = await repository.vote(projectId: 1, value: true);

      expect((result as Ok<ProjectVoteReceipt>).value, receipt);
    });

    test('unvote بترجّع Ok', () async {
      when(() => remote.unvote(projectId: 1)).thenAnswer((_) async {});

      expect(await repository.unvote(projectId: 1), isA<Ok>());
    });
  });
}
