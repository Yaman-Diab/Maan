import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maan/core/error/failure.dart';
import 'package:maan/core/result/result.dart';
import 'package:maan/core/session/account_status.dart';
import 'package:maan/core/session/app_session_controller.dart';
import 'package:maan/core/usecase/usecase.dart';
import 'package:maan/features/auth/domain/entities/auth_user.dart';
import 'package:maan/features/complaints/domain/usecases/get_my_complaints_usecase.dart';
import 'package:maan/features/home/presentation/home/cubit/home_cubit.dart';
import 'package:maan/features/home/presentation/home/cubit/home_state.dart';
import 'package:maan/features/news/domain/usecases/get_news_usecase.dart';
import 'package:maan/features/profile/domain/entities/citizen_profile.dart';
import 'package:maan/features/profile/domain/entities/profile_stats.dart';
import 'package:maan/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:maan/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetProfile extends Mock implements GetProfileUseCase {}

class _MockGetNews extends Mock implements GetNewsUseCase {}

class _MockGetProjects extends Mock implements GetProjectsUseCase {}

class _MockGetMyComplaints extends Mock implements GetMyComplaintsUseCase {}

class _MockSession extends Mock implements AppSessionController {}

/// ⚠️ **الفراغ الأبيض بآخر الرئيسية كان باگ حقيقي** — لما رجعت
/// المشاريع و«آخر شكاواي» فاضيتين مع بعض (حساب جديد، أو باك اند لسه
/// بلا بيانات)، القسمين كانوا يختفوا كلياً فتنتهي الصفحة فجأة بعد
/// «اختصارات سريعة». هالملف بيثبّت إن الحالة الفاضية بتوصل للواجهة
/// كحالة صريحة (`empty`) لا كإخفاء صامت.
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

    when(() => getProfile(any())).thenAnswer(
      (_) async => const Ok(
        CitizenProfile(
          user: AuthUser(
            id: 1,
            firstName: 'Ehsan',
            lastName: 'Sawan',
            email: 'a@b.com',
            accountStatus: AccountStatus.verified,
          ),
          stats: ProfileStats(citizenshipIndex: 100),
        ),
      ),
    );
    when(() => getNews(any())).thenAnswer((_) async => const Ok([]));
    when(() => getProjects(any())).thenAnswer((_) async => const Ok([]));
    when(() => getMyComplaints(any())).thenAnswer((_) async => const Ok([]));
  });

  HomeCubit build() =>
      HomeCubit(getProfile, getNews, getProjects, getMyComplaints, session);

  blocTest<HomeCubit, HomeState>(
    'كل الأقسام فاضية → حالات `empty` صريحة لا إخفاء (سبب الفراغ الأبيض)',
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      final state = cubit.state;

      expect(state.projectsStatus, HomeSectionStatus.empty);
      expect(state.complaintsStatus, HomeSectionStatus.empty);
      expect(state.newsStatus, HomeSectionStatus.empty);

      // الشاشة بتقرأ `isLoggedIn` حتى تعرض بطاقة «ما قدّمت شكوى بعد»
      // بدل ما تشيل القسم — الزائر وحده بينشال عنده.
      expect(state.isLoggedIn, isTrue);
      expect(state.showComplaints, isFalse);
    },
  );

  group('إعادة المحاولة لكل قسم', () {
    blocTest<HomeCubit, HomeState>(
      'retryProjects بتعيد تحميل المشاريع وحدها',
      setUp: () {
        var calls = 0;
        when(() => getProjects(any())).thenAnswer((_) async {
          calls++;
          return calls == 1
              ? const Err(NetworkFailure('error_connection'))
              : const Ok([]);
        });
      },
      build: build,
      act: (cubit) async {
        await cubit.load();
        expect(cubit.state.projectsStatus, HomeSectionStatus.error);
        await cubit.retryProjects();
      },
      verify: (cubit) {
        expect(cubit.state.projectsStatus, HomeSectionStatus.empty);
        // الأقسام التانية ما انطلبت من جديد.
        verify(() => getNews(any())).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      '⚠️ retryComplaints للزائر ما بتضرب الشبكة — 401 بيسجّل خروج',
      setUp: () {
        when(() => session.isLoggedIn).thenReturn(false);
        when(() => session.canUseMunicipalityServices).thenReturn(false);
      },
      build: build,
      act: (cubit) async {
        await cubit.load();
        await cubit.retryComplaints();
      },
      verify: (_) => verifyNever(() => getMyComplaints(any())),
    );
  });
}
