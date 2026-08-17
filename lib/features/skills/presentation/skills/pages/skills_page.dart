// -------------------------
// Skills Page
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../domain/entities/skill.dart';
import '../cubit/skills_cubit.dart';
import '../cubit/skills_state.dart';
import '../widgets/certificate_upload_sheet.dart';
import '../widgets/skill_card.dart';
import '../widgets/skill_form_sheet.dart';
import '../widgets/skills_skeleton.dart';
import '../widgets/skills_summary_card.dart';

class SkillsPage extends StatelessWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SkillsCubit>()..load(),
      child: const _SkillsView(),
    );
  }
}

class _SkillsView extends StatelessWidget {
  const _SkillsView();

  Future<void> _openDetail(BuildContext context, Skill skill) async {
    final changed = await context.push<bool>(
      AppRoutes.skillDetail,
      extra: skill,
    );

    if (changed == true && context.mounted) {
      context.read<SkillsCubit>().load();
    }
  }

  Future<void> _openCertificateAction(BuildContext context, Skill skill) async {
    final submitted = await showCertificateUploadSheet(context, skill: skill);

    if (submitted && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('skills_toast_certificate_submitted'.tr())),
        );
      context.read<SkillsCubit>().load();
    }
  }

  Future<void> _openAddSkill(BuildContext context) async {
    final saved = await showSkillFormSheet(context);

    if (saved && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('skills_toast_added'.tr())));
      context.read<SkillsCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'certificates_skills_title'.tr(),
          style: context.texts.f16W500Black.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSkill(context),
        icon: const Icon(Icons.add_rounded),
        label: Text('skills_add_fab'.tr()),
      ),
      body: SafeArea(
        child: BlocBuilder<SkillsCubit, SkillsState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<SkillsCubit>().load(),
              child: switch (state.status) {
                SkillsStatus.loading => ListView(
                  padding: EdgeInsets.all(16.w),
                  children: const [SkillsSkeleton()],
                ),
                SkillsStatus.error => ListView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  children: [
                    SizedBox(height: 120.h),
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48.sp,
                      color: colors.textHint,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      state.errorMessage ?? 'error_unknown'.tr(),
                      textAlign: TextAlign.center,
                      style: context.texts.f14W400HintColor,
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => context.read<SkillsCubit>().load(),
                        child: Text('retry'.tr()),
                      ),
                    ),
                  ],
                ),
                SkillsStatus.empty => ListView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  children: [
                    SizedBox(height: 90.h),
                    Icon(
                      Icons.workspace_premium_outlined,
                      size: 56.sp,
                      color: colors.textHint,
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'skills_empty_title'.tr(),
                      textAlign: TextAlign.center,
                      style: context.texts.f16W500Black.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'skills_empty_body'.tr(),
                      textAlign: TextAlign.center,
                      style: context.texts.f12W400SecColor.copyWith(
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Center(
                      child: FilledButton.icon(
                        onPressed: () => _openAddSkill(context),
                        icon: const Icon(Icons.add_rounded),
                        label: Text('skills_empty_action'.tr()),
                      ),
                    ),
                  ],
                ),
                SkillsStatus.ready => ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 96.h),
                  children: [
                    SkillsSummaryCard(
                      approved: state.approvedCount,
                      pending: state.pendingCount,
                      noCertificate: state.noCertificateCount,
                      total: state.skills.length,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.gpp_bad_outlined,
                          size: 14.sp,
                          color: colors.textHint,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            'skills_forged_notice'.tr(),
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: colors.textHint,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (state.hasPendingCertificate) ...[
                      SizedBox(height: AppSpacing.sm.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: colors.noticeBackground,
                          borderRadius: BorderRadius.circular(AppRadius.md.r),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18.sp,
                              color: colors.noticeForeground,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'skills_pending_notice'.tr(),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  height: 1.6,
                                  color: colors.noticeForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: AppSpacing.md.h),
                    Row(
                      children: [
                        Text(
                          'skills_list_title'.tr(),
                          style: context.texts.f14W600Black,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'skills_count_label'.tr(
                            namedArgs: {'count': '${state.skills.length}'},
                          ),
                          style: context.texts.f12W400SecColor,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    for (final skill in state.skills) ...[
                      SkillCard(
                        skill: skill,
                        onOpen: () => _openDetail(context, skill),
                        onCertificateAction: () =>
                            _openCertificateAction(context, skill),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                    ],
                  ],
                ),
              },
            );
          },
        ),
      ),
    );
  }
}
