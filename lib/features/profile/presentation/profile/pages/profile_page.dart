// -------------------------
// Profile Page
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/session/app_session_controller.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_content.dart';
import '../widgets/profile_error_view.dart';
import '../widgets/profile_guest_view.dart';

/// شاشة الملف الشخصي.
///
/// تاب جذر بالـ shell لا شاشة مكدّسة، فما فيها زر رجوع — التصميم بيرسم
/// سهماً لأنه مرسوم كشاشة منفردة، وزر رجوع بتاب بيرجّع لوين؟
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.onSignInTap, this.onSettingsTap});

  final VoidCallback onSignInTap;

  /// شاشة الإعدادات لسه ما انبنت (`SettingsCubit` جاهز بلا واجهة)، فبتوصل
  /// `null` والأيقونة ما بتنعرض. لما تجهز الشاشة، سطر واحد بالراوتر.
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final sessionController = sl<AppSessionController>();

    return Scaffold(
      backgroundColor: context.colors.pageBackground,
      appBar: AppBar(
        backgroundColor: context.colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16.w,
        title: Text(
          'profile_title'.tr(),
          style: context.texts.f16W500Black.copyWith(
            fontSize: 23.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (onSettingsTap != null)
            IconButton(
              onPressed: onSettingsTap,
              tooltip: 'settings'.tr(),
              icon: const Icon(Icons.settings_rounded),
            ),
          SizedBox(width: 8.w),
        ],
      ),

      // الجلسة ممكن تتغير والشاشة مفتوحة (تسجيل خروج من مكان تاني)،
      // فالاختيار بين عرض الزائر والملف لازم يعيد نفسه مع كل تغيير.
      body: AnimatedBuilder(
        animation: sessionController,
        builder: (context, _) {
          if (!sessionController.isLoggedIn) {
            return ProfileGuestView(onSignInTap: onSignInTap);
          }

          return BlocProvider<ProfileCubit>(
            create: (_) => sl<ProfileCubit>()..load(),
            child: const _ProfileBody(),
          );
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.isFirstLoad) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = state.profile;

        if (profile == null) {
          return ProfileErrorView(
            message: state.errorMessage ?? 'error_unknown'.tr(),
            onRetry: context.read<ProfileCubit>().load,
          );
        }

        return RefreshIndicator(
          onRefresh: context.read<ProfileCubit>().load,
          child: SingleChildScrollView(
            // `always` حتى يشتغل السحب للتحديث حتى لو المحتوى قصير.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
            child: ProfileContent(profile: profile),
          ),
        );
      },
    );
  }
}
