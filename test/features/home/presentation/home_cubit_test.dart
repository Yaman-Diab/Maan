import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/core/session/app_session_controller.dart';
import 'package:maan/core/usecase/usecase.dart';
import 'package:maan/features/auth/domain/entities/auth_user.dart';
import 'package:maan/features/complaints/domain/entities/complaint.dart';
import 'package:maan/features/complaints/domain/entities/complaint_status.dart';
import 'package:maan/features/complaints/domain/entities/complaint_type.dart';
import 'package:maan/features/complaints/domain/usecases/get_my_complaints_usecase.dart';
import 'package:maan/features/home/presentation/home/cubit/home_cubit.dart';
import 'package:maan/features/home/presentation/home/cubit/home_state.dart';
import 'package:maan/features/news/domain/entities/news_item.dart';
import 'package:maan/features/news/domain/usecases/get_news_usecase.dart';
import 'package:maan/features/profile/domain/entities/citizen_profile.dart';
import 'package:maan/features/profile/domain/entities/profile_stats.dart';
import 'package:maan/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:maan/features/projects/domain/entities/municipal_project.dart';
import 'package:maan/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetProfile extends Mock implements GetProfileUseCase {}

class _MockGetNews extends Mock implements GetNewsUseCase {}

class _MockGetProjects extends Mock implements GetProjectsUseCase {}

class _MockGetMyComplaints extends Mock implements GetMyComplaintsUseCase {}

class _MockSession extends Mock implements AppSessionController {}

CitizenProfile _profile() {
  return const CitizenProfile(
    user: AuthUser(
      id: 1,
      firstName: 'Yaman',
      lastName: 'Diab',
      email: 'a@b.com',
      accountStatus: AccountStatus.verified,
    ),
    stats: ProfileStats(citizenshipIndex: 65),
  );
}

Complaint _complaint({int id = 1}) {
  return Complaint(
    id: id,
    type: ComplaintType.individual,
    status: ComplaintStatus.underReview,
    title: 'شكوى $id',
  );
}

void main() {
  late _MockGetProfile getProfile;
  late _MockGetNews getNews;
  late _MockGetProjects getProjects;
  late _MockGetMyComplaints getMyComplaints;
  late _MockSession session;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const GetMyComplaintsParams(page: 1, pageSize: 3));
    registerFallbackValue(AccountStatus.verified);
  });

  setUp(() {
    getProfile = _MockGetProfile();
    getNews = _MockGetNews();
    getProjects = _MockGetProjects();
    getMyComplaints = _MockGetMyComplaints();
    session = _MockSession();

    when(() => session.isLoggedIn).thenReturn(true);
    when(() => session.canUseMunicipalityServices).thenReturn(true);
    when(() => session.accountStatusChanged(any())).thenAnswer((_) async {});

    when(() => getProfile(any())).thenAnswer((_) async => Ok(_profile()));
    when(
      () => getNews(any()),
    ).thenAnswer((_) async => const Ok([NewsItem(id: 1, title: 'خبر')]));
    when(() => getProjects(any())).thenAnswer(
      (_) async => const Ok([MunicipalProject(id: 1, title: 'مشروع')]),
    );
    when(
      () => getMyComplaints(any()),
    ).thenAnswer((_) async => Ok([_complaint()]));
  });

  HomeCubit build() =>
      HomeCubit(getProfile, getNews, getProjects, getMyComplaints, session);

  group('load — الحالة السعيدة', () {
    blocTest<HomeCubit, HomeState>(
      'كل الأقسام بتوصل ready',
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state;

        expect(state.profileStatus, HomeSectionStatus.ready);
        expect(state.newsStatus, HomeSectionStatus.ready);
        expect(state.projectsStatus, HomeSectionStatus.ready);
        expect(state.complaintsStatus, HomeSectionStatus.ready);
        expect(state.profile?.user.firstName, 'Yaman');
        expect(state.showComplaints, isTrue);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'بيبلّغ الجلسة بحالة الحساب — الملف الشخصي أحدث مصدر لها',
      build: build,
      act: (cubit) => cubit.load(),
      verify: (_) {
        verify(
          () => session.accountStatusChanged(AccountStatus.verified),
        ).called(1);
      },
    );
  });

  group('استقلال الأقسام — فشل واحد ما بيكسر الباقي', () {
    blocTest<HomeCubit, HomeState>(
      'فشل الأخبار: القسم error والباقي ready',
      setUp: () => when(
        () => getNews(any()),
      ).thenAnswer((_) async => const Err(NetworkFailure('error_connection'))),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state;

        expect(state.newsStatus, HomeSectionStatus.error);
        expect(state.profileStatus, HomeSectionStatus.ready);
        expect(state.projectsStatus, HomeSectionStatus.ready);
        expect(state.complaintsStatus, HomeSectionStatus.ready);
        // ⚠️ الأهم: الشاشة كلها ما بتنكسر بفشل قسم تكميلي.
        expect(state.hasProfileError, isFalse);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'فشل المشاريع: القسم error والأخبار بتضل ready',
      setUp: () => when(
        () => getProjects(any()),
      ).thenAnswer((_) async => const Err(NetworkFailure('error_connection'))),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.projectsStatus, HomeSectionStatus.error);
        expect(cubit.state.newsStatus, HomeSectionStatus.ready);
        expect(cubit.state.hasProfileError, isFalse);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'فشل الملف الشخصي **وحده** بيوقّع الشاشة كلها',
      setUp: () => when(
        () => getProfile(any()),
      ).thenAnswer((_) async => const Err(NetworkFailure('error_connection'))),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.hasProfileError, isTrue);
        expect(cubit.state.profileErrorMessage, 'error_connection');
      },
    );

    blocTest<HomeCubit, HomeState>(
      'retryNews بتعيد تحميل الأخبار وحدها',
      setUp: () {
        var attempts = 0;
        when(() => getNews(any())).thenAnswer((_) async {
          attempts++;
          return attempts == 1
              ? const Err(NetworkFailure('error_connection'))
              : const Ok([NewsItem(id: 9, title: 'خبر جديد')]);
        });
      },
      build: build,
      act: (cubit) async {
        await cubit.load();
        await cubit.retryNews();
      },
      verify: (cubit) {
        expect(cubit.state.newsStatus, HomeSectionStatus.ready);
        expect(cubit.state.news.single.id, 9);
        // الأقسام التانية ما انطلبت من جديد.
        verify(() => getProjects(any())).called(1);
      },
    );
  });

  group('الزائر', () {
    blocTest<HomeCubit, HomeState>(
      'ما بيضرب /api/profile ولا شكاواي — بس الأخبار والمشاريع',
      setUp: () {
        when(() => session.isLoggedIn).thenReturn(false);
        when(() => session.canUseMunicipalityServices).thenReturn(false);
      },
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        // ⚠️ حارس مهم: 401 من /api/profile بينفهم «انتهت الجلسة»
        // فبيسجّل خروج — نفس سبب الحارس بـ`ProfilePage`.
        verifyNever(() => getProfile(any()));
        verifyNever(() => getMyComplaints(any()));

        expect(cubit.state.profileStatus, HomeSectionStatus.empty);
        expect(cubit.state.complaintsStatus, HomeSectionStatus.empty);
        expect(cubit.state.newsStatus, HomeSectionStatus.ready);
        expect(cubit.state.showComplaints, isFalse);
        // ما بيعلق بالتحميل للأبد رغم إنه ما في طلب.
        expect(cubit.state.isFirstLoad, isFalse);
      },
    );
  });

  group('«آخر شكاواي»', () {
    blocTest<HomeCubit, HomeState>(
      'بلا شكاوى → القسم بيختفي كلياً',
      setUp: () => when(
        () => getMyComplaints(any()),
      ).thenAnswer((_) async => const Ok([])),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.complaintsStatus, HomeSectionStatus.empty);
        expect(cubit.state.showComplaints, isFalse);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'بتنقص لثلاثة كحد أقصى — الشريط تلخيص لا قائمة',
      setUp: () => when(() => getMyComplaints(any())).thenAnswer(
        (_) async => Ok([for (var i = 1; i <= 8; i++) _complaint(id: i)]),
      ),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) => expect(cubit.state.complaints.length, 3),
    );
  });
}
