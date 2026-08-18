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
    // افتراضي: التفاصيل مش متوفّرة إلا لو اختبار معيّن عدّل عليه صراحة —
    // نفس واقع فشل شبكة عابر، وبيتأكّد إنه ما بيكسر بقية الدمج.
    when(
      () => remote.getProjectDetail(any()),
    ).thenThrow(Exception('no detail stubbed'));
  });

  group('getProjects — دمج إحصائيات التبرعات', () {
    test('بتنجلب وبتنضم للكيان', () async {
      when(() => remote.getProjects()).thenAnswer((_) async => [_donating]);

      final result = await repository.getProjects();

      final project = (result as Ok<List<MunicipalProject>>).value.single;
      expect(project.donationStats, _stats);
      verify(() => remote.getDonationStats(1)).called(1);
    });

    test(
      '⚠️ بتنطلب لكل مشروع بلا استثناء — GET /api/project/votable ما '
      'بيرجّع requires_donations إطلاقاً فما في إشارة نصفّي عليها مسبقاً',
      () async {
        when(
          () => remote.getProjects(),
        ).thenAnswer((_) async => [_notDonating]);

        final result = await repository.getProjects();

        expect(
          (result as Ok<List<MunicipalProject>>).value.single.donationStats,
          _stats,
        );
        verify(() => remote.getDonationStats(2)).called(1);
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

  group('getProjects — دمج تفاصيل المشروع (GET /api/project/{id})', () {
    test('✅ imageUrl/location/requiresVolunteers/requiresDonations بتنضم '
        'من التفاصيل — votable ما بيرجّعهم أصلاً', () async {
      const bare = MunicipalProject(id: 5, title: 'مشروع بلا تفاصيل بعد');
      const detail = MunicipalProject(
        id: 5,
        title: 'مشروع بلا تفاصيل بعد',
        imageUrl: 'http://x/a.jpg',
        latitude: 33.5,
        longitude: 36.3,
        requiresVolunteers: true,
        volunteersNeeded: 7,
        volunteersApproved: 2,
        requiresDonations: true,
      );

      when(() => remote.getProjects()).thenAnswer((_) async => [bare]);
      when(() => remote.getProjectDetail(5)).thenAnswer((_) async => detail);

      final result = await repository.getProjects();
      final project = (result as Ok<List<MunicipalProject>>).value.single;

      expect(project.imageUrl, 'http://x/a.jpg');
      expect(project.latitude, 33.5);
      expect(project.requiresVolunteers, isTrue);
      expect(project.volunteersNeeded, 7);
      expect(project.volunteersApproved, 2);
      expect(project.requiresDonations, isTrue);
    });

    test(
      '⚠️ فشل جلب التفاصيل ما بيكسر القائمة ولا بيغيّر حقول التصويت',
      () async {
        const withVotes = MunicipalProject(
          id: 6,
          title: 'مشروع',
          totalVotes: 4,
          weightedYesVotes: 10,
        );

        when(() => remote.getProjects()).thenAnswer((_) async => [withVotes]);
        when(
          () => remote.getProjectDetail(6),
        ).thenThrow(Exception('detail endpoint down'));

        final result = await repository.getProjects();
        final project = (result as Ok<List<MunicipalProject>>).value.single;

        expect(project.requiresVolunteers, isFalse);
        expect(project.imageUrl, isNull);
        // حقول التصويت من votable ما تأثّرت بفشل التفاصيل.
        expect(project.totalVotes, 4);
        expect(project.weightedYesVotes, 10);
      },
    );
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
