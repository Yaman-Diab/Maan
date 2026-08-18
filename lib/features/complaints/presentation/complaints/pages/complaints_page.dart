// -------------------------
// Complaints Page
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_button.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/result/result.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../domain/entities/complaint.dart';
import '../../../domain/entities/complaint_category.dart';
import '../../../domain/entities/complaint_sort.dart';
import '../../../domain/entities/complaint_type.dart';
import '../../shared/complaint_style.dart';
import '../cubit/complaints_cubit.dart';
import '../cubit/complaints_state.dart';
import '../widgets/complaint_card.dart';
import '../widgets/complaint_sort_sheet.dart';
import '../widgets/complaints_skeleton.dart';

/// شاشة الشكاوى — تاب ثالث بالشريط السفلي. عرض واحد بحالات أربع
/// (تحميل/فاضية/خطأ/جاهزة) بدل أربع شاشات، نفس نمط شاشة التوثيق.
class ComplaintsPage extends StatelessWidget {
  const ComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ComplaintsCubit>(
      create: (_) => sl<ComplaintsCubit>()..load(),
      child: const _ComplaintsBody(),
    );
  }
}

class _ComplaintsBody extends StatelessWidget {
  const _ComplaintsBody();

  Future<void> _openSort(BuildContext context, ComplaintsState state) async {
    final cubit = context.read<ComplaintsCubit>();
    final sort = await showComplaintSortSheet(context, selected: state.sort);

    if (sort != null) await cubit.setSort(sort);
  }

  Future<void> _openDetail(BuildContext context, Complaint complaint) async {
    final cubit = context.read<ComplaintsCubit>();

    await context.push(AppRoutes.complaintDetail, extra: complaint);

    if (context.mounted) await cubit.load();
  }

  Future<void> _openSubmit(BuildContext context, bool canParticipate) async {
    if (!canParticipate) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('complaint_submit_locked'.tr())));
      return;
    }

    final cubit = context.read<ComplaintsCubit>();
    final submitted = await context.push<bool>(AppRoutes.submitComplaint);

    if (submitted == true && context.mounted) {
      await cubit.changeTab(ComplaintsTab.mine);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.pageBackground,
      appBar: AppBar(
        backgroundColor: context.colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16.w,
        title: Text(
          'complaints_title'.tr(),
          style: context.texts.f16W500Black.copyWith(
            fontSize: 23.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<ComplaintsCubit, ComplaintsState>(
        builder: (context, state) {
          final cubit = context.read<ComplaintsCubit>();

          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                    child: _TabSegment(
                      tab: state.tab,
                      onChanged: cubit.changeTab,
                    ),
                  ),
                  // فلاتر النوع والتصنيف بتشتغل بس مع الشكاوى المنشورة —
                  // `GET /api/complains/my-complains` بياخد `page`/
                  // `page_size` بس (راجع collection.md)، ما عندها `type`
                  // ولا `category_id`. بلا هالشرط كانت الفلاتر بتظهر
                  // وتستجيب باللمس بتاب «شكاواي» بلا أي أثر فعلي على
                  // النتائج — لبس تحديد بلا تنفيذ.
                  if (state.tab == ComplaintsTab.published) ...[
                    SizedBox(
                      height: 44.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        children: [
                          _SortButton(
                            sort: state.sort,
                            onTap: () => _openSort(context, state),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 1,
                            height: 26.h,
                            color: context.colors.divider,
                          ),
                          SizedBox(width: 8.w),
                          _FilterChip(
                            label: 'complaint_type_all'.tr(),
                            icon: Icons.filter_list_rounded,
                            selected: state.typeFilter == null,
                            onTap: () => cubit.setTypeFilter(null),
                          ),
                          for (final type in ComplaintType.values) ...[
                            SizedBox(width: 8.w),
                            _FilterChip(
                              label: switch (type) {
                                ComplaintType.individual =>
                                  'complaint_type_individual'.tr(),
                                ComplaintType.collective =>
                                  'complaint_type_collective'.tr(),
                                ComplaintType.emergency =>
                                  'complaint_type_emergency'.tr(),
                              },
                              icon: ComplaintStyle.type(context, type).icon,
                              selected: state.typeFilter == type,
                              onTap: () => cubit.setTypeFilter(type),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 40.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        children: [
                          _FilterChip(
                            label: 'cat_all'.tr(),
                            icon: Icons.apps_rounded,
                            selected: state.categoryFilter == null,
                            onTap: () => cubit.setCategoryFilter(null),
                          ),
                          for (final category in ComplaintCategory.values) ...[
                            SizedBox(width: 8.w),
                            _FilterChip(
                              label: _categoryLabel(category),
                              icon: ComplaintStyle.category(
                                context,
                                category,
                              ).icon,
                              selected: state.categoryFilter == category,
                              onTap: () => cubit.setCategoryFilter(category),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],
                  if (!state.canParticipate)
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                      child: _VerifyBanner(
                        onTap: () => context.push(AppRoutes.verification),
                      ),
                    ),
                  Expanded(
                    child: _Content(
                      state: state,
                      onOpen: (c) => _openDetail(context, c),
                    ),
                  ),
                ],
              ),
              PositionedDirectional(
                bottom: 16.h,
                end: 16.w,
                child: _SubmitFab(
                  enabled: state.canParticipate,
                  onTap: () => _openSubmit(context, state.canParticipate),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _categoryLabel(ComplaintCategory category) {
    return switch (category) {
      ComplaintCategory.roads => 'cat_roads'.tr(),
      ComplaintCategory.waste => 'cat_waste'.tr(),
      ComplaintCategory.lighting => 'cat_lighting'.tr(),
      ComplaintCategory.water => 'cat_water'.tr(),
      ComplaintCategory.publicServices => 'cat_public'.tr(),
      ComplaintCategory.other => 'cat_other'.tr(),
    };
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, required this.onOpen});

  final ComplaintsState state;
  final ValueChanged<Complaint> onOpen;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      ComplaintsListStatus.loading => const ComplaintsSkeleton(),
      ComplaintsListStatus.error => _ErrorView(
        message: state.errorMessage ?? 'error_unknown'.tr(),
        onRetry: context.read<ComplaintsCubit>().retry,
      ),
      ComplaintsListStatus.empty => _EmptyView(
        onSubmit: state.canParticipate
            ? () => context.push<bool>(AppRoutes.submitComplaint).then((
                submitted,
              ) {
                if (submitted == true && context.mounted) {
                  context.read<ComplaintsCubit>().load();
                }
              })
            : null,
      ),
      ComplaintsListStatus.ready => _List(state: state, onOpen: onOpen),
    };
  }
}

class _List extends StatelessWidget {
  const _List({required this.state, required this.onOpen});

  final ComplaintsState state;
  final ValueChanged<Complaint> onOpen;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ComplaintsCubit>();

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
      itemCount: state.items.length + 1,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Column(
              children: [
                if (state.hasMore)
                  TextButton.icon(
                    onPressed: state.isLoadingMore ? null : cubit.loadMore,
                    icon: Icon(Icons.expand_more_rounded, size: 19.sp),
                    label: Text('complaints_load_more'.tr()),
                  ),
                Text(
                  'complaints_page_label'.tr(
                    namedArgs: {
                      'shown': '${state.items.length}',
                      'total':
                          '${state.items.length}${state.hasMore ? '+' : ''}',
                    },
                  ),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: context.colors.textHint,
                  ),
                ),
              ],
            ),
          );
        }

        final complaint = state.items[index];

        return ComplaintCard(
          complaint: complaint,
          canVote: state.canParticipate,
          onTap: () => onOpen(complaint),
          onVoteTap: () async {
            if (!state.canParticipate) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('complaint_vote_locked'.tr())),
                );
              return;
            }

            final result = await cubit.toggleVote(complaint);

            // ⚠️ تعارض حقيقي وارد (409 صوّت قبل هيك من جهاز تاني، مثلاً)
            // — الفشل بلا رسالة كان رح يخلّي المستخدم يشوف البطاقة
            // ترجع لحالتها القديمة بلا أي تفسير.
            if (result case Err(:final failure)) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(failure.message)));
            }
          },
        );
      },
    );
  }
}

class _TabSegment extends StatelessWidget {
  const _TabSegment({required this.tab, required this.onChanged});

  final ComplaintsTab tab;
  final ValueChanged<ComplaintsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: context.colors.trackBackground,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabSegmentItem(
              label: 'complaints_tab_published'.tr(),
              selected: tab == ComplaintsTab.published,
              onTap: () => onChanged(ComplaintsTab.published),
            ),
          ),
          Expanded(
            child: _TabSegmentItem(
              label: 'complaints_tab_mine'.tr(),
              selected: tab == ComplaintsTab.mine,
              onTap: () => onChanged(ComplaintsTab.mine),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSegmentItem extends StatelessWidget {
  const _TabSegmentItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(vertical: 9.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? scheme.onPrimary : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.sort, required this.onTap});

  final ComplaintSort sort;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: context.scheme.surface,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_vert_rounded,
              size: 18.sp,
              color: context.scheme.primary,
            ),
            SizedBox(width: 6.w),
            Text(
              switch (sort) {
                ComplaintSort.priority => 'complaint_sort_priority'.tr(),
                ComplaintSort.newest => 'complaint_sort_newest'.tr(),
                ComplaintSort.oldest => 'complaint_sort_oldest'.tr(),
              },
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.brandSurface : scheme.surface,
          border: Border.all(color: selected ? scheme.primary : colors.border),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17.sp,
              color: selected ? scheme.primary : colors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? scheme.primary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifyBanner extends StatelessWidget {
  const _VerifyBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: colors.brandSurface,
          border: Border.all(color: scheme.primary),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 22.sp,
              color: scheme.primary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'complaints_verify_title'.tr(),
                    style: context.texts.f14W600Black,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'complaints_verify_subtitle'.tr(),
                    style: context.texts.f12W400SecColor,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitFab extends StatelessWidget {
  const _SubmitFab({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(16.r),
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            height: 56.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 22.sp, color: scheme.onPrimary),
                SizedBox(width: 8.w),
                Text(
                  'complaint_submit_cta'.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onSubmit});

  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                color: colors.brandSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.campaign_rounded,
                size: 40.sp,
                color: scheme.primary,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'complaints_empty_title'.tr(),
              style: context.texts.f16W500Black.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'complaints_empty_body'.tr(),
              textAlign: TextAlign.center,
              style: context.texts.f14W400HintColor.copyWith(
                color: colors.textSecondary,
                height: 1.6,
              ),
            ),
            if (onSubmit != null) ...[
              SizedBox(height: 20.h),
              AppButton(
                buttonText: 'complaints_empty_action'.tr(),
                buttonOnPressed: onSubmit!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 72.sp,
              color: context.colors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.texts.f14W400HintColor.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            AppButton(buttonText: 'retry'.tr(), buttonOnPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
