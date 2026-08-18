// -------------------------
// News Page
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/app_state_view.dart';
import '../../../../../core/di/service_locator.dart';
import '../cubit/news_cubit.dart';
import '../cubit/news_state.dart';
import '../widgets/news_card.dart';
import '../widgets/news_skeleton.dart';

/// تاب «الأخبار والإعلانات» — عرض فقط، بلا أي إجراء.
class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NewsCubit>()..load(),
      child: const _NewsView(),
    );
  }
}

class _NewsView extends StatelessWidget {
  const _NewsView();

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
          'news_header'.tr(),
          style: context.texts.f16W500Black.copyWith(
            fontSize: 23.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<NewsCubit, NewsState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<NewsCubit>().load(),
              child: switch (state.status) {
                NewsStatus.loading => ListView(
                  padding: EdgeInsets.all(16.w),
                  children: const [NewsSkeleton()],
                ),
                NewsStatus.error => ListView(
                  padding: EdgeInsets.only(top: 120.h),
                  children: [
                    AppStateView(
                      icon: Icons.cloud_off_rounded,
                      message: state.errorMessage ?? 'news_load_failed'.tr(),
                      actionLabel: 'retry'.tr(),
                      onAction: () => context.read<NewsCubit>().load(),
                    ),
                  ],
                ),
                NewsStatus.empty => ListView(
                  padding: EdgeInsets.only(top: 110.h),
                  children: [
                    AppStateView(
                      icon: Icons.feed_outlined,
                      title: 'news_empty_title'.tr(),
                      message: 'news_empty_body'.tr(),
                    ),
                  ],
                ),
                NewsStatus.ready => ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 28.h),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm.h),
                  itemBuilder: (context, index) =>
                      NewsCard(item: state.items[index]),
                ),
              },
            );
          },
        ),
      ),
    );
  }
}
