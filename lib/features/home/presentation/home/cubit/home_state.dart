// -------------------------
// Home State
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../../complaints/domain/entities/complaint.dart';
import '../../../../news/domain/entities/news_item.dart';
import '../../../../profile/domain/entities/citizen_profile.dart';
import '../../../../projects/domain/entities/municipal_project.dart';

/// حالة كل قسم لحاله — الشاشة بتجمع أربع مصادر مستقلة، وفشل واحد
/// **ما لازم يكسر الباقي**: الأخبار ممكن تفشل بينما المشاريع بتنجح.
enum HomeSectionStatus { loading, ready, empty, error }

final class HomeState extends Equatable {
  /// الملف الشخصي هو القسم **الوحيد** اللي فشله بيوقّع الشاشة كلها —
  /// بلاه ما في اسم بالترحيب ولا مؤشر مواطنة ولا حتى معرفة إذا لازم
  /// يظهر بانر التوثيق. الباقي أقسام تكميلية.
  final HomeSectionStatus profileStatus;
  final CitizenProfile? profile;
  final String? profileErrorMessage;

  final HomeSectionStatus newsStatus;
  final List<NewsItem> news;

  final HomeSectionStatus projectsStatus;
  final List<MunicipalProject> projects;

  final HomeSectionStatus complaintsStatus;
  final List<Complaint> complaints;

  /// المستخدم داخل فعلاً — الزائر ما بيضرب `/api/profile` أصلاً (401
  /// بينفهم «انتهت الجلسة» فبيسجّل خروج، نفس حارس `ProfilePage`).
  final bool isLoggedIn;

  /// الحساب موثّق فيقدر يتطوّع ويصوّت ويقدّم شكاوى.
  final bool canParticipate;

  const HomeState({
    this.profileStatus = HomeSectionStatus.loading,
    this.profile,
    this.profileErrorMessage,
    this.newsStatus = HomeSectionStatus.loading,
    this.news = const [],
    this.projectsStatus = HomeSectionStatus.loading,
    this.projects = const [],
    this.complaintsStatus = HomeSectionStatus.loading,
    this.complaints = const [],
    this.isLoggedIn = false,
    this.canParticipate = false,
  });

  /// أول تحميل للشاشة كاملة — الهيكل بيغطّي كل الأقسام مرة وحدة بدل
  /// أربع هياكل بتوصل بأوقات مختلفة فتقفز الشاشة.
  bool get isFirstLoad =>
      profileStatus == HomeSectionStatus.loading && profile == null;

  bool get hasProfileError => profileStatus == HomeSectionStatus.error;

  /// «آخر شكاواي» بتختفي كلياً لو ما في ولا شكوى — مش حالة فارغة
  /// بأيقونة، القسم نفسه بينشال (قرار التصميم).
  bool get showComplaints =>
      isLoggedIn && complaintsStatus == HomeSectionStatus.ready;

  /// ⚠️ **`profileErrorMessage` بتنحفظ افتراضياً لا بتنمسح** — عكس نمط
  /// `errorMessage` بباقي الحالات بالمشروع. السبب: الأقسام بتنزل
  /// بالتوازي، فأي قسم بيخلص بعد فشل الملف الشخصي بينادي `copyWith`
  /// بلا الرسالة — ومع نمط «امسح افتراضياً» كانت الرسالة تختفي وتصير
  /// شاشة خطأ بلا سبب. المسح صريح عبر [clearProfileError] وقت
  /// `load()` بس.
  HomeState copyWith({
    HomeSectionStatus? profileStatus,
    CitizenProfile? profile,
    String? profileErrorMessage,
    bool clearProfileError = false,
    HomeSectionStatus? newsStatus,
    List<NewsItem>? news,
    HomeSectionStatus? projectsStatus,
    List<MunicipalProject>? projects,
    HomeSectionStatus? complaintsStatus,
    List<Complaint>? complaints,
    bool? isLoggedIn,
    bool? canParticipate,
  }) {
    return HomeState(
      profileStatus: profileStatus ?? this.profileStatus,
      profile: profile ?? this.profile,
      profileErrorMessage: clearProfileError
          ? null
          : (profileErrorMessage ?? this.profileErrorMessage),
      newsStatus: newsStatus ?? this.newsStatus,
      news: news ?? this.news,
      projectsStatus: projectsStatus ?? this.projectsStatus,
      projects: projects ?? this.projects,
      complaintsStatus: complaintsStatus ?? this.complaintsStatus,
      complaints: complaints ?? this.complaints,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      canParticipate: canParticipate ?? this.canParticipate,
    );
  }

  @override
  List<Object?> get props => [
    profileStatus,
    profile,
    profileErrorMessage,
    newsStatus,
    news,
    projectsStatus,
    projects,
    complaintsStatus,
    complaints,
    isLoggedIn,
    canParticipate,
  ];
}
