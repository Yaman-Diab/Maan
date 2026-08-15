import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/session/app_session_controller.dart';
import 'package:maan/features/complaints/domain/entities/complaint.dart';
import 'package:maan/features/complaints/domain/entities/complaint_sort.dart';
import 'package:maan/features/complaints/domain/entities/complaint_status.dart';
import 'package:maan/features/complaints/domain/entities/complaint_type.dart';
import 'package:maan/features/complaints/domain/usecases/get_my_complaints_usecase.dart';
import 'package:maan/features/complaints/domain/usecases/get_published_complaints_usecase.dart';
import 'package:maan/features/complaints/domain/usecases/unvote_complaint_usecase.dart';
import 'package:maan/features/complaints/domain/usecases/vote_complaint_usecase.dart';
import 'package:maan/features/complaints/presentation/complaints/cubit/complaints_cubit.dart';
import 'package:maan/features/complaints/presentation/complaints/cubit/complaints_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetPublished extends Mock implements GetPublishedComplaintsUseCase {}

class _MockGetMine extends Mock implements GetMyComplaintsUseCase {}

class _MockVote extends Mock implements VoteComplaintUseCase {}

class _MockUnvote extends Mock implements UnvoteComplaintUseCase {}

class _MockSession extends Mock implements AppSessionController {}

Complaint _complaint({int id = 1, bool hasVoted = false, int votes = 0}) {
  return Complaint(
    id: id,
    type: ComplaintType.individual,
    status: ComplaintStatus.underReview,
    title: 'شكوى $id',
    votes: votes,
    hasVoted: hasVoted,
  );
}

void main() {
  late _MockGetPublished getPublished;
  late _MockGetMine getMine;
  late _MockVote vote;
  late _MockUnvote unvote;
  late _MockSession session;

  setUpAll(() {
    registerFallbackValue(
      const GetPublishedComplaintsParams(
        sort: ComplaintSort.priority,
        page: 1,
        pageSize: 10,
      ),
    );
    registerFallbackValue(const GetMyComplaintsParams(page: 1, pageSize: 10));
  });

  setUp(() {
    getPublished = _MockGetPublished();
    getMine = _MockGetMine();
    vote = _MockVote();
    unvote = _MockUnvote();
    session = _MockSession();

    when(() => session.canUseMunicipalityServices).thenReturn(true);
  });

  ComplaintsCubit build() =>
      ComplaintsCubit(getPublished, getMine, vote, unvote, session);

  group('load', () {
    blocTest<ComplaintsCubit, ComplaintsState>(
      'ناجح بقائمة أقل من حجم الصفحة → ready بلا hasMore',
      setUp: () => when(() => getPublished(any())).thenAnswer(
        (_) async => Ok([_complaint()]),
      ),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        predicate<ComplaintsState>((s) => s.status == ComplaintsListStatus.loading),
        predicate<ComplaintsState>(
          (s) =>
              s.status == ComplaintsListStatus.ready &&
              s.items.length == 1 &&
              s.hasMore == false &&
              s.canParticipate == true,
        ),
      ],
    );

    blocTest<ComplaintsCubit, ComplaintsState>(
      'قائمة فاضية → empty',
      setUp: () => when(() => getPublished(any())).thenAnswer((_) async => const Ok([])),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        predicate<ComplaintsState>((s) => s.status == ComplaintsListStatus.loading),
        predicate<ComplaintsState>((s) => s.status == ComplaintsListStatus.empty),
      ],
    );

    blocTest<ComplaintsCubit, ComplaintsState>(
      'فشل الطلب → error برسالة الفشل',
      setUp: () => when(() => getPublished(any())).thenAnswer(
        (_) async => const Err(NetworkFailure('error_connection')),
      ),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        predicate<ComplaintsState>((s) => s.status == ComplaintsListStatus.loading),
        predicate<ComplaintsState>(
          (s) =>
              s.status == ComplaintsListStatus.error &&
              s.errorMessage == 'error_connection',
        ),
      ],
    );
  });

  group('تبديل التاب', () {
    blocTest<ComplaintsCubit, ComplaintsState>(
      'شكاواي بتنادي GetMyComplaintsUseCase لا GetPublished',
      setUp: () {
        when(() => getPublished(any())).thenAnswer((_) async => const Ok([]));
        when(() => getMine(any())).thenAnswer((_) async => Ok([_complaint()]));
      },
      build: build,
      act: (cubit) async {
        await cubit.load();
        await cubit.changeTab(ComplaintsTab.mine);
      },
      verify: (_) {
        verify(() => getMine(any())).called(1);
        verify(() => getPublished(any())).called(1);
      },
    );
  });

  group('التصويت — تفاؤلي مع تراجع عند الفشل', () {
    blocTest<ComplaintsCubit, ComplaintsState>(
      'نجح: العدّاد والحالة يضلّوا متغيّرين',
      setUp: () {
        when(() => getPublished(any())).thenAnswer(
          (_) async => Ok([_complaint(votes: 3)]),
        );
        when(() => vote(any())).thenAnswer((_) async => const Ok(null));
      },
      build: build,
      act: (cubit) async {
        await cubit.load();
        await cubit.toggleVote(cubit.state.items.first);
      },
      skip: 2,
      expect: () => [
        predicate<ComplaintsState>(
          (s) => s.items.first.hasVoted == true && s.items.first.votes == 4,
        ),
      ],
    );

    blocTest<ComplaintsCubit, ComplaintsState>(
      'فشل: يرجع للحالة الأصلية',
      setUp: () {
        when(() => getPublished(any())).thenAnswer(
          (_) async => Ok([_complaint(votes: 3)]),
        );
        when(() => vote(any())).thenAnswer(
          (_) async => const Err(NetworkFailure('error_connection')),
        );
      },
      build: build,
      act: (cubit) async {
        await cubit.load();
        await cubit.toggleVote(cubit.state.items.first);
      },
      skip: 3,
      expect: () => [
        predicate<ComplaintsState>(
          (s) => s.items.first.hasVoted == false && s.items.first.votes == 3,
        ),
      ],
    );

    blocTest<ComplaintsCubit, ComplaintsState>(
      'غير موثّق (canParticipate false) — ما بيصوّت أصلاً',
      setUp: () {
        when(() => session.canUseMunicipalityServices).thenReturn(false);
        when(() => getPublished(any())).thenAnswer(
          (_) async => Ok([_complaint(votes: 3)]),
        );
      },
      build: build,
      act: (cubit) async {
        await cubit.load();
        await cubit.toggleVote(cubit.state.items.first);
      },
      verify: (_) {
        verifyNever(() => vote(any()));
      },
    );
  });
}
