import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/session/app_session_controller.dart';
import 'package:maan/core/usecase/usecase.dart';
import 'package:maan/features/projects/domain/entities/municipal_project.dart';
import 'package:maan/features/projects/domain/entities/project_reaction.dart';
import 'package:maan/features/projects/domain/entities/project_vote_receipt.dart';
import 'package:maan/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:maan/features/projects/domain/usecases/unvote_project_usecase.dart';
import 'package:maan/features/projects/domain/usecases/vote_project_usecase.dart';
import 'package:maan/features/projects/presentation/projects/cubit/projects_cubit.dart';
import 'package:maan/features/projects/presentation/projects/cubit/projects_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetProjects extends Mock implements GetProjectsUseCase {}

class _MockVote extends Mock implements VoteProjectUseCase {}

class _MockUnvote extends Mock implements UnvoteProjectUseCase {}

class _MockSession extends Mock implements AppSessionController {}

const _project = MunicipalProject(
  id: 1,
  title: 'مشروع',
  totalVotes: 10,
  weightedYesVotes: 20,
  weightedOpposeVotes: 5,
);

void main() {
  late _MockGetProjects getProjects;
  late _MockVote vote;
  late _MockUnvote unvote;
  late _MockSession session;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const VoteProjectParams(projectId: 1, value: true));
    registerFallbackValue(const UnvoteProjectParams(projectId: 1));
  });

  setUp(() {
    getProjects = _MockGetProjects();
    vote = _MockVote();
    unvote = _MockUnvote();
    session = _MockSession();

    when(() => session.canUseMunicipalityServices).thenReturn(true);
    when(
      () => getProjects(any()),
    ).thenAnswer((_) async => const Ok([_project]));
    when(() => vote(any())).thenAnswer(
      (_) async => const Ok(
        ProjectVoteReceipt(
          projectId: 1,
          value: true,
          voteWeight: 3,
          citizenshipScoreAtVoteTime: 40,
        ),
      ),
    );
    when(() => unvote(any())).thenAnswer((_) async => const Ok(null));
  });

  ProjectsCubit build() => ProjectsCubit(getProjects, vote, unvote, session);

  group('vote — تصويت جديد (POST)', () {
    blocTest<ProjectsCubit, ProjectsState>(
      'أحبذ من none بيرسل POST بـvalue:true وبيحدّث العدّاد المرجَّح بوزن السيرفر',
      build: build,
      act: (cubit) async {
        await cubit.load();
        await cubit.vote(_project, true);
      },
      verify: (cubit) {
        verify(
          () => vote(const VoteProjectParams(projectId: 1, value: true)),
        ).called(1);

        final updated = cubit.state.items.single;
        expect(updated.myReaction, ProjectReaction.favor);
        expect(updated.weightedYesVotes, 23); // 20 + وزن السيرفر (3)
        expect(updated.weightedOpposeVotes, 5);
        expect(updated.totalVotes, 11);
        expect(cubit.state.votingIds, isEmpty);
      },
    );

    blocTest<ProjectsCubit, ProjectsState>(
      'لا أحبذ من none بيرسل POST بـvalue:false',
      build: build,
      act: (cubit) async {
        await cubit.load();
        await cubit.vote(_project, false);
      },
      verify: (cubit) {
        verify(
          () => vote(const VoteProjectParams(projectId: 1, value: false)),
        ).called(1);
        verifyNever(() => unvote(any()));
      },
    );

    blocTest<ProjectsCubit, ProjectsState>(
      'فشل الـPOST (409 مثلاً) بيرجّع الفشل وبيفضّي votingIds بلا تغيير حالة',
      setUp: () => when(
        () => vote(any()),
      ).thenAnswer((_) async => const Err(NetworkFailure('error_conflict'))),
      build: build,
      act: (cubit) async {
        await cubit.load();
        await cubit.vote(_project, true);
      },
      verify: (cubit) {
        expect(cubit.state.items.single.myReaction, ProjectReaction.none);
        expect(cubit.state.votingIds, isEmpty);
      },
    );

    blocTest<ProjectsCubit, ProjectsState>(
      'غير موثّق → ما بيصير أي استدعاء شبكة',
      setUp: () =>
          when(() => session.canUseMunicipalityServices).thenReturn(false),
      build: build,
      act: (cubit) async {
        await cubit.load();
        await cubit.vote(_project, true);
      },
      verify: (cubit) {
        verifyNever(() => vote(any()));
        expect(cubit.state.items.single.myReaction, ProjectReaction.none);
      },
    );
  });

  group('vote — سحب (DELETE)', () {
    blocTest<ProjectsCubit, ProjectsState>(
      'الضغط على الخيار المفعّل حالياً بيسحب الصوت — DELETE بلا POST',
      setUp: () {
        // أول تحميل (`load`) بيرجّع المشروع مصوَّت عليه (أحبذ)؛ إعادة
        // التحميل الصامتة بعد السحب لازم ترجّع السيرفر الحقيقي (بلا
        // تصويت) — نفس تسلسل الحقيقة لو صار سباق بين الاثنين.
        var calls = 0;
        when(() => getProjects(any())).thenAnswer((_) async {
          calls++;
          return Ok([
            MunicipalProject(
              id: 1,
              title: 'مشروع',
              totalVotes: 10,
              weightedYesVotes: 20,
              weightedOpposeVotes: 5,
              myReaction: calls == 1
                  ? ProjectReaction.favor
                  : ProjectReaction.none,
            ),
          ]);
        });
      },
      build: build,
      act: (cubit) async {
        await cubit.load();
        final favored = cubit.state.items.single;
        await cubit.vote(favored, true); // نفس الخيار المفعّل = سحب
      },
      verify: (cubit) {
        verify(() => unvote(const UnvoteProjectParams(projectId: 1))).called(1);
        verifyNever(() => vote(any()));

        // السحب بيحدّث myReaction فوراً بس ما بيلمس العدّاد المرجَّح
        // محلياً — إعادة تحميل صامتة بالخلفية هي يلي بتصحّحه.
        expect(cubit.state.items.single.myReaction, ProjectReaction.none);
      },
    );

    blocTest<ProjectsCubit, ProjectsState>(
      'السحب بيطلق إعادة تحميل صامتة بالخلفية — getProjects بتنطلب مرة تانية',
      setUp: () {
        when(() => getProjects(any())).thenAnswer(
          (_) async => const Ok([
            MunicipalProject(
              id: 1,
              title: 'مشروع',
              myReaction: ProjectReaction.favor,
            ),
          ]),
        );
      },
      build: build,
      act: (cubit) async {
        await cubit.load();
        final favored = cubit.state.items.single;
        await cubit.vote(favored, true);
        // السحب بيطلق `_fetch()` بلا await (`unawaited`) — لازم ننتظر
        // Microtask/IO دورة حتى تخلص قبل ما نتأكّد.
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      verify: (_) {
        // مرة من `load()`، ومرة من إعادة التحميل الصامتة بعد السحب.
        verify(() => getProjects(any())).called(2);
      },
    );
  });

  group('vote — تبديل (DELETE ثم POST)', () {
    blocTest<ProjectsCubit, ProjectsState>(
      'الضغط على لا أحبذ وأنا مفعّل أحبذ بيسحب الأول وبعدين يبعت الجديد',
      setUp: () {
        // أول تحميل: أحبذ. إعادة التحميل الصامتة بعد التبديل (تصير
        // مرة وحدة بعد ما الـPOST الجديد يخلص) لازم ترجّع السيرفر
        // الحقيقي بعد التبديل — لا أحبذ.
        var calls = 0;
        when(() => getProjects(any())).thenAnswer((_) async {
          calls++;
          return Ok([
            MunicipalProject(
              id: 1,
              title: 'مشروع',
              totalVotes: 10,
              weightedYesVotes: 20,
              weightedOpposeVotes: 5,
              myReaction: calls == 1
                  ? ProjectReaction.favor
                  : ProjectReaction.oppose,
            ),
          ]);
        });
      },
      build: build,
      act: (cubit) async {
        await cubit.load();
        final favored = cubit.state.items.single;
        await cubit.vote(favored, false); // معاكس المفعّل = تبديل
      },
      verify: (cubit) {
        verify(() => unvote(const UnvoteProjectParams(projectId: 1))).called(1);
        verify(
          () => vote(const VoteProjectParams(projectId: 1, value: false)),
        ).called(1);

        expect(cubit.state.items.single.myReaction, ProjectReaction.oppose);
      },
    );

    blocTest<ProjectsCubit, ProjectsState>(
      'فشل السحب بالتبديل بيوقف العملية — POST الجديد ما بينبعت أصلاً',
      setUp: () {
        when(() => getProjects(any())).thenAnswer(
          (_) async => const Ok([
            MunicipalProject(
              id: 1,
              title: 'مشروع',
              myReaction: ProjectReaction.favor,
            ),
          ]),
        );
        when(() => unvote(any())).thenAnswer(
          (_) async => const Err(NetworkFailure('error_connection')),
        );
      },
      build: build,
      act: (cubit) async {
        await cubit.load();
        final favored = cubit.state.items.single;
        await cubit.vote(favored, false);
      },
      verify: (cubit) {
        verifyNever(() => vote(any()));
        // الرأي بيضل أحبذ (السحب فشل، ما تغيّر شي فعلياً على السيرفر).
        expect(cubit.state.items.single.myReaction, ProjectReaction.favor);
      },
    );
  });

  group('حماية أساسية', () {
    blocTest<ProjectsCubit, ProjectsState>(
      'ضغطتين متتاليتين بلا انتظار — الثانية no-op لأن الأولى لسه شغّالة',
      build: build,
      act: (cubit) async {
        await cubit.load();
        // ما منستنى الأولى قبل ما نطلق الثانية.
        final first = cubit.vote(_project, true);
        final second = cubit.vote(_project, true);
        await Future.wait([first, second]);
      },
      verify: (_) {
        verify(() => vote(any())).called(1);
      },
    );
  });
}
