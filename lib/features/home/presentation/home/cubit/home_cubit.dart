// -------------------------
// Home Cubit
// -------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/result/result.dart';
import '../../../../../core/session/app_session_controller.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../../complaints/domain/usecases/get_my_complaints_usecase.dart';
import '../../../../news/domain/usecases/get_news_usecase.dart';
import '../../../../profile/domain/usecases/get_profile_usecase.dart';
import '../../../../projects/domain/usecases/get_projects_usecase.dart';
import 'home_state.dart';

/// شاشة الرئيسية بتجمع أربع مصادر مستقلة. كل قسم بينزل **بالتوازي**
/// وبيحدّث حالته لحاله — فأول قسم بيوصل بينعرض فوراً بدل ما ينتظر
/// الأبطأ، وفشل قسم ما بيمنع الباقي (راجع `HomeState`).
class HomeCubit extends Cubit<HomeState> {
  final GetProfileUseCase _getProfile;
  final GetNewsUseCase _getNews;
  final GetProjectsUseCase _getProjects;
  final GetMyComplaintsUseCase _getMyComplaints;
  final AppSessionController _session;

  /// كم شكوى بتظهر بشريط «آخر شكاواي» — الشريط تلخيص لا قائمة كاملة،
  /// وتاب الشكاوى موجود لعرض الكل.
  static const int _complaintsPreviewCount = 3;

  HomeCubit(
    this._getProfile,
    this._getNews,
    this._getProjects,
    this._getMyComplaints,
    this._session,
  ) : super(const HomeState());

  Future<void> load() async {
    final isLoggedIn = _session.isLoggedIn;

    emit(
      state.copyWith(
        isLoggedIn: isLoggedIn,
        canParticipate: _session.canUseMunicipalityServices,
        // المسح الوحيد لرسالة خطأ الملف الشخصي — راجع تعليق
        // `HomeState.copyWith`.
        clearProfileError: true,
        profileStatus: isLoggedIn
            ? HomeSectionStatus.loading
            // الزائر ما إله ملف شخصي — بلا هالفرع رح يضل عالق بالتحميل
            // للأبد لأنه ما في طلب رح يوصل.
            : HomeSectionStatus.empty,
        newsStatus: HomeSectionStatus.loading,
        projectsStatus: HomeSectionStatus.loading,
        complaintsStatus: isLoggedIn
            ? HomeSectionStatus.loading
            : HomeSectionStatus.empty,
      ),
    );

    // ما منستنى وحدة قبل التانية — كلهم بيمشوا بالتوازي.
    await Future.wait([
      if (isLoggedIn) _loadProfile(),
      _loadNews(),
      _loadProjects(),
      if (isLoggedIn) _loadComplaints(),
    ]);
  }

  Future<void> retryNews() => _loadNews();

  Future<void> retryProjects() => _loadProjects();

  /// الزائر ما إله شكاوى — بلا هالحارس رح يضرب `my-complains` فيرجع
  /// 401 و`AuthInterceptor` يفهمها «انتهت الجلسة» فيسجّل خروج.
  Future<void> retryComplaints() async {
    if (!state.isLoggedIn) return;

    await _loadComplaints();
  }

  Future<void> _loadProfile() async {
    final result = await _getProfile(const NoParams());

    if (isClosed) return;

    switch (result) {
      case Ok(:final value):
        // الملف الشخصي أحدث مصدر لحالة الحساب — التوثيق ممكن يكون
        // اعتُمد بعد آخر تسجيل دخول (نفس منطق `ProfileCubit`).
        await _session.accountStatusChanged(value.user.accountStatus);

        if (isClosed) return;

        emit(
          state.copyWith(
            profileStatus: HomeSectionStatus.ready,
            profile: value,
            canParticipate: _session.canUseMunicipalityServices,
          ),
        );

      case Err(:final failure):
        emit(
          state.copyWith(
            profileStatus: HomeSectionStatus.error,
            profileErrorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> _loadNews() async {
    emit(state.copyWith(newsStatus: HomeSectionStatus.loading));

    final result = await _getNews(const NoParams());

    if (isClosed) return;

    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            newsStatus: value.isEmpty
                ? HomeSectionStatus.empty
                : HomeSectionStatus.ready,
            news: value,
          ),
        );

      case Err():
        emit(state.copyWith(newsStatus: HomeSectionStatus.error));
    }
  }

  Future<void> _loadProjects() async {
    emit(state.copyWith(projectsStatus: HomeSectionStatus.loading));

    final result = await _getProjects(const NoParams());

    if (isClosed) return;

    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            projectsStatus: value.isEmpty
                ? HomeSectionStatus.empty
                : HomeSectionStatus.ready,
            projects: value,
          ),
        );

      case Err():
        emit(state.copyWith(projectsStatus: HomeSectionStatus.error));
    }
  }

  Future<void> _loadComplaints() async {
    emit(state.copyWith(complaintsStatus: HomeSectionStatus.loading));

    final result = await _getMyComplaints(
      const GetMyComplaintsParams(page: 1, pageSize: _complaintsPreviewCount),
    );

    if (isClosed) return;

    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            complaintsStatus: value.isEmpty
                ? HomeSectionStatus.empty
                : HomeSectionStatus.ready,
            complaints: value.take(_complaintsPreviewCount).toList(),
          ),
        );

      case Err():
        emit(state.copyWith(complaintsStatus: HomeSectionStatus.error));
    }
  }
}
