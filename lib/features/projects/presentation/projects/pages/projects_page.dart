// -------------------------
// Projects Page
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_state_view.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/result/result.dart';
import '../cubit/projects_cubit.dart';
import '../cubit/projects_state.dart';
import '../widgets/project_card.dart';
import '../widgets/projects_skeleton.dart';

/// تاب «المشاريع البلدية».
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProjectsCubit>()..load(),
      child: const _ProjectsView(),
    );
  }
}

class _ProjectsView extends StatelessWidget {
  const _ProjectsView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16.w,
        title: Text(
          'projects_header'.tr(),
          style: context.texts.f16W500Black.copyWith(
            fontSize: 23.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<ProjectsCubit, ProjectsState>(
          builder: (context, state) {
            final cubit = context.read<ProjectsCubit>();

            return RefreshIndicator(
              onRefresh: cubit.load,
              child: switch (state.status) {
                ProjectsStatus.loading => ListView(
                  padding: EdgeInsets.all(16.w),
                  children: const [ProjectsSkeleton()],
                ),
                ProjectsStatus.error => ListView(
                  padding: EdgeInsets.only(top: 120.h),
                  children: [
                    AppStateView(
                      icon: Icons.cloud_off_rounded,
                      message:
                          state.errorMessage ?? 'projects_load_failed'.tr(),
                      actionLabel: 'retry'.tr(),
                      onAction: cubit.load,
                    ),
                  ],
                ),
                ProjectsStatus.empty => ListView(
                  padding: EdgeInsets.only(top: 110.h),
                  children: [
                    AppStateView(
                      icon: Icons.apartment_outlined,
                      title: 'projects_empty_title'.tr(),
                      message: 'projects_empty_body'.tr(),
                    ),
                  ],
                ),
                ProjectsStatus.ready => ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 28.h),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm.h),
                  itemBuilder: (context, index) {
                    final project = state.items[index];

                    return ProjectCard(
                      project: project,
                      canParticipate: state.canParticipate,
                      voting: state.votingIds.contains(project.id),
                      onReactionTap: (project, value) async {
                        if (!state.canParticipate) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text('project_vote_locked'.tr()),
                              ),
                            );
                          return;
                        }

                        final result = await cubit.vote(project, value);

                        if (result case Err(
                          :final failure,
                        ) when context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(content: Text(failure.message)),
                            );
                        }
                      },
                    );
                  },
                ),
              },
            );
          },
        ),
      ),
    );
  }
}
