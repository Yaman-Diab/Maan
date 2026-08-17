// -------------------------
// Municipal Services Page
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_spacing.dart';
import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../domain/entities/municipal_service.dart';
import '../cubit/municipal_services_cubit.dart';
import '../cubit/municipal_services_state.dart';
import '../widgets/municipal_service_card.dart';
import '../widgets/municipal_services_skeleton.dart';

/// شاشة «خدمات البلدية» — للعرض فقط، بلا أي تفاعل مع نظام الطابور
/// الفعلي (`Queue/Citizen` خارج نطاق تطبيق المواطن كلياً). كل خدمة
/// بتعرض وقتاً مقدّراً لدور المواطن، محسوباً محلياً — راجع
/// `MunicipalService.estimatedWaitMinutes`.
class MunicipalServicesPage extends StatelessWidget {
  const MunicipalServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MunicipalServicesCubit>()..load(),
      child: const _MunicipalServicesView(),
    );
  }
}

class _MunicipalServicesView extends StatelessWidget {
  const _MunicipalServicesView();

  /// النشطة أولاً حسب أسرع وقت مقدّر، وغير النشطة دائماً بآخر القائمة
  /// بغض النظر عن أي حساب وقت — نفس منطق التصميم.
  static List<MunicipalService> _sorted(List<MunicipalService> services) {
    final active = services.where((s) => s.isActive).toList()
      ..sort(
        (a, b) => a.estimatedWaitMinutes.compareTo(b.estimatedWaitMinutes),
      );
    final inactive = services.where((s) => !s.isActive).toList();

    return [...active, ...inactive];
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
          'municipal_services_title'.tr(),
          style: context.texts.f16W500Black.copyWith(
            fontSize: 23.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<MunicipalServicesCubit, MunicipalServicesState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<MunicipalServicesCubit>().load(),
              child: switch (state.status) {
                MunicipalServicesStatus.loading => ListView(
                  padding: EdgeInsets.all(16.w),
                  children: const [MunicipalServicesSkeleton()],
                ),
                MunicipalServicesStatus.error => ListView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  children: [
                    SizedBox(height: 120.h),
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 72.sp,
                      color: colors.textSecondary,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.errorMessage ?? 'error_unknown'.tr(),
                      textAlign: TextAlign.center,
                      style: context.texts.f14W400HintColor,
                    ),
                    SizedBox(height: 24.h),
                    Center(
                      child: FilledButton(
                        onPressed: () =>
                            context.read<MunicipalServicesCubit>().load(),
                        style: FilledButton.styleFrom(
                          minimumSize: Size(180.w, 52.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md.r),
                          ),
                        ),
                        child: Text('retry'.tr()),
                      ),
                    ),
                  ],
                ),
                MunicipalServicesStatus.empty => ListView(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  children: [
                    SizedBox(height: 110.h),
                    Container(
                      width: 88.w,
                      height: 88.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.brandSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.apartment_rounded,
                        size: 40.sp,
                        color: context.scheme.primary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'municipal_services_empty_title'.tr(),
                      textAlign: TextAlign.center,
                      style: context.texts.f16W500Black.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'municipal_services_empty_body'.tr(),
                      textAlign: TextAlign.center,
                      style: context.texts.f12W400SecColor.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
                MunicipalServicesStatus.ready => ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 28.h),
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14.sp,
                          color: colors.textSecondary,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'municipal_services_last_updated'.tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    for (final service in _sorted(state.services)) ...[
                      MunicipalServiceCard(service: service),
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
