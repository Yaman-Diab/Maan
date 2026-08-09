// -------------------------
// Profile Page
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/design_system/app_theme_context.dart';
import '../../../../../core/design_system/widgets/image_source_sheet.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/media/image_picker_service.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/session/app_session_controller.dart';
import '../../../domain/entities/citizen_profile.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_content.dart';
import '../widgets/profile_error_view.dart';
import '../widgets/profile_guest_view.dart';
import '../widgets/profile_skeleton.dart';

/// شاشة الملف الشخصي.
///
/// تاب جذر بالـ shell لا شاشة مكدّسة، فما فيها زر رجوع — التصميم بيرسم
/// سهماً لأنه مرسوم كشاشة منفردة، وزر رجوع بتاب بيرجّع لوين؟
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.onSignInTap, this.onSettingsTap});

  final VoidCallback onSignInTap;

  /// اختياري بالتوقيع بس `AppRouter` بيمرّره دائماً — الثيم واللغة
  /// وحجم الخط مفيدة للزائر كمان، فأيقونة الإعدادات بتظهر بشريط الأدوات
  /// المشترك بغضّ النظر عن حالة الدخول. `SettingsPage` نفسها بتخفي قسم
  /// «الحساب» (خروج/حذف) للزائر — راجع تعليقها.
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

  /// خط الأنابيب: ورقة الاختيار ← اختيار ← قص ← ضغط ← رفع (أو إزالة
  /// مباشرة لو هيك اختار).
  ///
  /// الإلغاء بأي خطوة بيرجّع `null` وبنوقف بهدوء — مش خطأ.
  Future<void> _changeAvatar(BuildContext context, {required bool hasAvatar}) async {
    final cubit = context.read<ProfileCubit>();

    // بتتبنى قبل أي `await`: بعد الفجوة الزمنية ممكن يكون الـ context
    // انفصل عن الشجرة.
    final appearance = _cropperAppearance(context);

    final action = await showImageSourceSheet(
      context,
      title: 'avatar_sheet_title'.tr(),
      cameraLabel: 'avatar_source_camera'.tr(),
      galleryLabel: 'avatar_source_gallery'.tr(),
      showRemoveOption: hasAvatar,
      removeLabel: 'avatar_source_remove'.tr(),
    );

    if (action == null) return;

    if (action == ImageSourceAction.remove) {
      await cubit.removeAvatar();
      return;
    }

    final source = action == ImageSourceAction.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    final image = await sl<ImagePickerService>().pickAvatar(
      source: source,
      appearance: appearance,
    );

    if (image == null) return;

    await cubit.uploadAvatar(image);
  }

  /// بيفتح شاشة التعديل وبيحدّث الملف عند الرجوع بنجاح — `true` بس لو
  /// الشاشة قفلت نفسها بعد حفظ ناجح (راجع `EditIdentityPage`).
  Future<void> _editIdentity(BuildContext context, CitizenProfile profile) async {
    final cubit = context.read<ProfileCubit>();

    final saved = await context.push<bool>(
      AppRoutes.editIdentity,
      extra: profile.user,
    );

    if (saved != true || !context.mounted) return;

    await cubit.load();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('identity_updated_message'.tr())));
  }

  /// بيفتح شاشة التوثيق وبيحدّث الملف عند الرجوع.
  ///
  /// إعادة التحميل بلا شرط — على عكس `_editIdentity` الشاشة ما بترجّع
  /// نتيجة: المستخدم ممكن يكون بعت طلباً (فحالة الحساب تغيّرت) أو بس
  /// تفرّج ورجع، وسؤال `GET /api/profile` أرخص من تتبّع النية.
  Future<void> _openVerification(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();

    await context.push(AppRoutes.verification);

    if (!context.mounted) return;

    await cubit.load();
  }

  /// ⏳ بتنقل لـ`_TempPage` حالياً — الشاشة الحقيقية لسه ما انبنت،
  /// راجع `AppRoutes.certificatesAndSkills`.
  void _openCertificates(BuildContext context) {
    context.push(AppRoutes.certificatesAndSkills);
  }

  static CropperAppearance _cropperAppearance(BuildContext context) {
    final scheme = context.scheme;

    return CropperAppearance(
      toolbarTitle: 'avatar_crop_title'.tr(),
      toolbarColor: scheme.primary,
      toolbarWidgetColor: scheme.onPrimary,
      backgroundColor: scheme.surface,
      activeControlsWidgetColor: scheme.primary,
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
  }

  void _onStateChanged(BuildContext context, ProfileState state) {
    final message = state.avatarErrorMessage;

    if (message == null) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: _onStateChanged,
      builder: (context, state) {
        if (state.isFirstLoad) {
          return const ProfileSkeleton();
        }

        final profile = state.profile;

        if (profile == null) {
          return ProfileErrorView(
            message: state.errorMessage ?? 'error_unknown'.tr(),
            onRetry: context.read<ProfileCubit>().load,
          );
        }

        // «إزالة الصورة» بورقة الاختيار ما إلها معنى لو ما في صورة
        // حالياً — محلية ولا من السيرفر.
        final hasAvatar =
            state.localAvatarPath != null || state.displayedAvatarUrl != null;

        return RefreshIndicator(
          onRefresh: context.read<ProfileCubit>().load,
          child: SingleChildScrollView(
            // `always` حتى يشتغل السحب للتحديث حتى لو المحتوى قصير.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
            child: ProfileContent(
              profile: profile,
              localAvatarPath: state.localAvatarPath,
              avatarRemoved: state.avatarRemoved,
              isUploadingAvatar: state.isUploadingAvatar,
              isRemovingAvatar: state.isRemovingAvatar,
              onAddPhotoTap: () =>
                  _changeAvatar(context, hasAvatar: hasAvatar),
              onEditTap: () => _editIdentity(context, profile),
              onVerifyTap: () => _openVerification(context),
              onCertificatesTap: () => _openCertificates(context),
            ),
          ),
        );
      },
    );
  }
}
