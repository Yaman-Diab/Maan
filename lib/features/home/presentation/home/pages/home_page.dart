// -------------------------
// Home Page
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_state_view.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../complaints/domain/entities/complaint.dart';
import '../../../../news/presentation/news/widgets/news_card.dart';
import '../../../../news/presentation/news/widgets/news_skeleton.dart';
import '../../../../projects/presentation/projects/widgets/project_card.dart';
import '../../../../projects/presentation/projects/widgets/projects_skeleton.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/home_banners.dart';
import '../widgets/home_complaint_tile.dart';
import '../widgets/home_header.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/home_section_header.dart';
import '../widgets/home_skeleton.dart';

/// تاب الرئيسية — «شو بقدر أعمل هلأ، وشو الجديد».
///
/// ما بتكرّر محتوى الملف الشخصي (حالة التوثيق التفصيلية، المؤشرات
/// الكاملة، الشهادات) — دور الملف الشخصي «مين أنا»، ودور هاي «شو
/// بيصير». المؤشر الوحيد المكرّر شارة المواطنة المصغّرة بالهيدر،
/// كلمسة تحفيزية لا كبديل عن البطاقة الكاملة.
///
/// تاب جذر بالـshell — بلا زر رجوع.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  /// ⚠️ التصويت على المشاريع **بلا عقد باك اند** — التبديل محلي بس،
  /// راجع `ProjectsCubit.toggleVote` و`MunicipalProject.votes`. الرئيسية
  /// ما بتصوّت أصلاً: البطاقة هون للعرض، والتصويت بتاب المشاريع.
  Future<void> _openSubmitComplaint(BuildContext context) async {
    final cubit = context.read<HomeCubit>();
    final submitted = await context.push<bool>(AppRoutes.submitComplaint);

    if (submitted == true && context.mounted) await cubit.load();
  }

  Future<void> _openComplaintDetail(
    BuildContext context,
    Complaint complaint,
  ) async {
    final cubit = context.read<HomeCubit>();

    await context.push(AppRoutes.complaintDetail, extra: complaint);

    if (context.mounted) await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final cubit = context.read<HomeCubit>();

            return RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 28.h),
                children: [
                  HomeHeaderSection(state: state),
                  SizedBox(height: 18.h),
                  if (state.isFirstLoad)
                    const HomeSkeleton()
                  else if (state.hasProfileError)
                    Padding(
                      padding: EdgeInsets.only(top: 90.h),
                      child: AppStateView(
                        icon: Icons.cloud_off_rounded,
                        message:
                            state.profileErrorMessage ??
                            'home_error_message'.tr(),
                        actionLabel: 'retry'.tr(),
                        onAction: cubit.load,
                      ),
                    )
                  else
                    ..._buildSections(context, state, cubit),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildSections(
    BuildContext context,
    HomeState state,
    HomeCubit cubit,
  ) {
    return [
      if (state.isLoggedIn && !state.canParticipate) ...[
        HomeVerifyBanner(onTap: () => context.push(AppRoutes.verification)),
        SizedBox(height: 22.h),
      ],

      HomeEmergencyBanner(onTap: () => _openSubmitComplaint(context)),
      SizedBox(height: 22.h),

      _NewsSection(state: state, onRetry: cubit.retryNews),

      SizedBox(height: 22.h),
      HomeSectionHeader(title: 'home_quick_header'.tr()),
      SizedBox(height: 12.h),
      HomeQuickActions(
        onSubmitComplaint: () => _openSubmitComplaint(context),
        onMunicipalServices: () => context.push(AppRoutes.municipalServices),
        onSkills: () => context.push(AppRoutes.certificatesAndSkills),
      ),

      SizedBox(height: 22.h),
      _ProjectsSection(state: state, onRetry: cubit.retryProjects),

      // القسم بيظهر لكل مستخدم مسجّل — حتى بلا شكاوى. الزائر وحده
      // بينشال عنده (ما إله شكاوى أصلاً، ولا بيقدر يقدّم).
      if (state.isLoggedIn) ...[
        SizedBox(height: 22.h),
        HomeSectionHeader(
          title: 'home_my_complaints_header'.tr(),
          onViewAll: state.showComplaints
              ? () => context.go(AppRoutes.complaints)
              : null,
        ),
        SizedBox(height: 12.h),
        if (state.showComplaints)
          for (final complaint in state.complaints) ...[
            HomeComplaintTile(
              complaint: complaint,
              onTap: () => _openComplaintDetail(context, complaint),
            ),
            if (complaint != state.complaints.last) SizedBox(height: 10.h),
          ]
        else if (state.complaintsStatus == HomeSectionStatus.loading)
          const ProjectsSkeleton(count: 1)
        else if (state.complaintsStatus == HomeSectionStatus.error)
          _HomeSectionCard(
            icon: Icons.cloud_off_rounded,
            message: 'home_my_complaints_failed'.tr(),
            actionLabel: 'retry'.tr(),
            onAction: cubit.retryComplaints,
          )
        else
          // فاضي → بطاقة بتدفع للإجراء الأساسي بدل فراغ صامت.
          _HomeSectionCard(
            icon: Icons.campaign_outlined,
            message: 'home_my_complaints_empty'.tr(),
            actionLabel: 'complaint_submit_cta'.tr(),
            onAction: () => _openSubmitComplaint(context),
          ),
      ],
    ];
  }
}

/// منفصل حتى ما يعيد `HomePage` بناء الهيدر مع كل تغيّر قسم.
class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({super.key, required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final user = state.profile?.user;

    return HomeHeader(
      firstName: user?.firstName,
      citizenshipScore: state.profile?.stats.citizenshipIndex,
    );
  }
}

class _NewsSection extends StatelessWidget {
  const _NewsSection({required this.state, required this.onRetry});

  final HomeState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          title: 'news_header'.tr(),
          onViewAll: () => context.go(AppRoutes.news),
        ),
        SizedBox(height: 12.h),
        switch (state.newsStatus) {
          // ⚠️ فشل الأخبار بيعرض بطاقة مصغّرة بمكانها بس — ما بيكسر
          // باقي الشاشة (المشاريع ممكن تكون نجحت).
          HomeSectionStatus.error => Container(
            padding: EdgeInsets.symmetric(vertical: 18.h),
            decoration: BoxDecoration(
              color: context.scheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
              boxShadow: AppShadows.shadowSm,
            ),
            child: AppStateView(
              compact: true,
              icon: Icons.cloud_off_rounded,
              message: 'news_load_failed'.tr(),
              actionLabel: 'retry'.tr(),
              onAction: onRetry,
            ),
          ),
          HomeSectionStatus.loading => const NewsSkeleton(horizontal: true),
          HomeSectionStatus.empty => Container(
            padding: EdgeInsets.symmetric(vertical: 18.h),
            decoration: BoxDecoration(
              color: context.scheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
              boxShadow: AppShadows.shadowSm,
            ),
            child: AppStateView(
              compact: true,
              icon: Icons.feed_outlined,
              message: 'news_empty_title'.tr(),
            ),
          ),
          // ⚠️ `SingleChildScrollView(Row(...))` لا `SizedBox(height) +
          // ListView.horizontal` — الشكل التاني بيفرض نفس الارتفاع
          // الثابت على كل بطاقة (محور ListView العرضي بيمدد أي عنصر
          // ليملأ ارتفاع الـSizedBox كاملاً)، بغض النظر عن ارتفاع
          // محتواها الفعلي، فبيصير فراغ أبيض شاغل تحت النص — نفس
          // البطاقات بلا هالمشكلة بتاب الأخبار (ListView **عمودي** ما
          // بيمدد الارتفاع، بس العرض). `Row` هون بياخد ارتفاعه من أطول
          // بطاقة فعلياً.
          HomeSectionStatus.ready => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in state.news) ...[
                  NewsCard(item: item, compact: true),
                  if (item != state.news.last) SizedBox(width: 12.w),
                ],
              ],
            ),
          ),
        },
      ],
    );
  }
}

class _ProjectsSection extends StatelessWidget {
  const _ProjectsSection({required this.state, required this.onRetry});

  final HomeState state;
  final VoidCallback onRetry;

  /// الرئيسية بتعرض عيّنة بس — تاب المشاريع للقائمة الكاملة.
  static const int _previewCount = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          title: 'projects_header'.tr(),
          onViewAll: () => context.go(AppRoutes.projects),
        ),
        SizedBox(height: 12.h),
        switch (state.projectsStatus) {
          HomeSectionStatus.loading => const ProjectsSkeleton(
            count: _previewCount,
          ),
          // ⚠️ **بطاقة حالة لا إخفاء** — كان القسم بيختفي كلياً بالفاضي
          // أو الخطأ، وهاد بالضبط يلي عمل «فراغ أبيض بآخر الرئيسية» لما
          // رجعت المشاريع والشكاوى فاضيتين مع بعض: الصفحة بتخلص فجأة بعد
          // الاختصارات بلا أي تفسير. راجع تعليق `_HomeSectionCard`.
          HomeSectionStatus.error => _HomeSectionCard(
            icon: Icons.cloud_off_rounded,
            message: 'projects_load_failed'.tr(),
            actionLabel: 'retry'.tr(),
            onAction: onRetry,
          ),
          HomeSectionStatus.empty => _HomeSectionCard(
            icon: Icons.apartment_outlined,
            message: 'projects_empty_title'.tr(),
          ),
          HomeSectionStatus.ready => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final project in state.projects.take(_previewCount)) ...[
                ProjectCard(
                  project: project,
                  canParticipate: state.canParticipate,
                ),
                if (project != state.projects.take(_previewCount).last)
                  SizedBox(height: 12.h),
              ],
            ],
          ),
        },
      ],
    );
  }
}

/// بطاقة حالة مصغّرة لقسم بالرئيسية (فاضي أو فشل) — بتملأ مكان القسم
/// بدل ما يختفي.
///
/// ⚠️ **إخفاء القسم بالفاضي كان باگ عرض حقيقي**: لما رجعت المشاريع
/// و«آخر شكاواي» فاضيتين بنفس الوقت (حساب جديد، أو باك اند لسه بلا
/// بيانات)، الصفحة كانت تنتهي فجأة بعد «اختصارات سريعة» وتترك فراغاً
/// أبيض كبير للأسفل — المستخدم بيقرأها «الصفحة خربانة» لا «ما في
/// بيانات». بطاقة صغيرة بتفسّر الحالة أوضح بكتير من فراغ صامت.
class _HomeSectionCard extends StatelessWidget {
  const _HomeSectionCard({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      decoration: BoxDecoration(
        color: context.scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        boxShadow: AppShadows.shadowSm,
      ),
      child: AppStateView(
        compact: true,
        icon: icon,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}
