// -------------------------
// Settings Page
// -------------------------

import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/design_system/app_theme_context.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/app_section_header.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/permissions/app_permission_service.dart';
import '../../../../core/session/app_session_controller.dart';
import '../../../../core/settings/cubit/settings_cubit.dart';
import '../../../../core/settings/cubit/settings_state.dart';
import '../widgets/settings_confirm_sheet.dart';
import '../widgets/settings_row.dart';
import '../widgets/settings_segmented_control.dart';
import '../widgets/settings_text_scale_row.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showSettingsConfirmSheet(
      context: context,
      title: 'logout_confirm_title'.tr(),
      body: 'logout_confirm_body'.tr(),
      confirmLabel: 'logout'.tr(),
      confirmColor: context.scheme.primary,
    );

    if (!confirmed || !context.mounted) return;

    await sl<AppSessionController>().logout();

    // الملف الشخصي عم يسمع لنفس المتحكّم وبيتحوّل لعرض الزائر بمجرّد
    // ما يصير `isLoggedIn` false — نرجع له بدل ما نضل فوق شاشة إعدادات
    // ما إلها معنى لزائر.
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showSettingsConfirmSheet(
      context: context,
      title: 'delete_account_confirm_title'.tr(),
      body: 'delete_account_confirm_body'.tr(),
      confirmLabel: 'delete_account'.tr(),
      confirmColor: context.scheme.error,
    );

    if (!confirmed || !context.mounted) return;

    // ⚠️ ما في endpoint لحذف الحساب لحد الآن — راجع CLAUDE.md. الورقة
    // مبنية كاملة حتى تكون جاهزة، بس ما بتنفّذ حذفاً حقيقياً.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('delete_account_not_available'.tr())));
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('coming_soon'.tr())));
  }

  Future<void> _openSystemSettings(BuildContext context) {
    return sl<AppPermissionService>().openSystemSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.pageBackground,
      appBar: AppBar(
        backgroundColor: context.colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'settings'.tr(),
          style: context.texts.f16W500Black.copyWith(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------
              // Appearance
              // -------------------------
              AppSectionHeader(title: 'settings_appearance'.tr()),
              SizedBox(height: 12.h),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settings) {
                  final cubit = context.read<SettingsCubit>();

                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 13.h,
                          ),
                          child: _SettingsControlRow(
                            label: 'settings_theme'.tr(),
                            control: SettingsSegmentedControl<ThemeMode>(
                              selected: settings.themeMode,
                              onChanged: cubit.setThemeMode,
                              options: [
                                SettingsSegmentedOption(
                                  value: ThemeMode.system,
                                  label: 'theme_system'.tr(),
                                ),
                                SettingsSegmentedOption(
                                  value: ThemeMode.light,
                                  label: 'theme_light'.tr(),
                                ),
                                SettingsSegmentedOption(
                                  value: ThemeMode.dark,
                                  label: 'theme_dark'.tr(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SettingsRowDivider(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 11.h,
                          ),
                          child: _SettingsControlRow(
                            label: 'settings_text_size'.tr(),
                            control: SettingsTextScaleRow(
                              selected: settings.textScale,
                              onChanged: cubit.setTextScale,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 22.h),

              // -------------------------
              // Language
              // -------------------------
              AppSectionHeader(title: 'settings_language'.tr()),
              SizedBox(height: 12.h),
              AppCard(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
                child: _SettingsControlRow(
                  label: 'settings_language'.tr(),
                  control: SettingsSegmentedControl<String>(
                    selected: context.locale.languageCode,
                    onChanged: (code) => context.setLocale(Locale(code)),
                    options: [
                      SettingsSegmentedOption(
                        value: 'en',
                        label: 'language_english'.tr(),
                      ),
                      SettingsSegmentedOption(
                        value: 'ar',
                        label: 'language_arabic'.tr(),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 22.h),

              // -------------------------
              // Privacy & Permissions
              // -------------------------
              AppSectionHeader(title: 'settings_privacy_permissions'.tr()),
              SizedBox(height: 12.h),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SettingsRow(
                      leadingIcon: Icons.location_on_rounded,
                      iconBadgeColor: context.colors.brandSurface,
                      iconColor: context.scheme.primary,
                      label: 'location_access'.tr(),
                      onTap: () => _openSystemSettings(context),
                    ),
                    const SettingsRowDivider(),
                    SettingsRow(
                      leadingIcon: Icons.photo_camera_rounded,
                      iconBadgeColor: context.colors.brandSurface,
                      iconColor: context.scheme.primary,
                      label: 'camera_and_photos'.tr(),
                      onTap: () => _openSystemSettings(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(4.w, 10.h, 4.w, 0),
                child: Text(
                  'permission_usage_caption'.tr(),
                  style: context.texts.f12W400SecColor.copyWith(
                    height: 1.5,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),

              SizedBox(height: 22.h),

              // -------------------------
              // About
              // -------------------------
              AppSectionHeader(title: 'settings_about'.tr()),
              SizedBox(height: 12.h),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SettingsRow(
                      label: 'app_version'.tr(),
                      showChevron: false,
                      trailing: const _AppVersionValue(),
                    ),
                    const SettingsRowDivider(),
                    SettingsRow(
                      label: 'contact_support'.tr(),
                      onTap: () => _showComingSoon(context),
                    ),
                    const SettingsRowDivider(),
                    SettingsRow(
                      label: 'terms_and_conditions'.tr(),
                      onTap: () => _showComingSoon(context),
                    ),
                    const SettingsRowDivider(),
                    SettingsRow(
                      label: 'privacy_policy'.tr(),
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Center(
                  child: Text(
                    'about_footer'.tr(),
                    textAlign: TextAlign.center,
                    style: context.texts.f12W400SecColor.copyWith(
                      fontSize: 11.5.sp,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ),

              // -------------------------
              // Account
              // -------------------------
              //
              // بلا معنى لزائر ما سجّل دخوله — لا خروج من جلسة ما
              // موجودة، ولا حساب يُحذف. `AnimatedBuilder` بدل فحص وحيد
              // لحظة البناء لأنه ممكن يسجّل خروج من مكان تاني والشاشة
              // مفتوحة (نفس نمط `ProfilePage`).
              AnimatedBuilder(
                animation: sl<AppSessionController>(),
                builder: (context, _) {
                  if (!sl<AppSessionController>().isLoggedIn) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 22.h),
                      AppSectionHeader(title: 'settings_account'.tr()),
                      SizedBox(height: 12.h),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: SettingsRow(
                          leadingIcon: Icons.logout_rounded,
                          iconColor: context.scheme.primary,
                          label: 'logout'.tr(),
                          onTap: () => _logout(context),
                        ),
                      ),
                      SizedBox(height: 48.h),
                      SettingsRow(
                        leadingIcon: Icons.delete_outline_rounded,
                        iconColor: context.scheme.error,
                        label: 'delete_account'.tr(),
                        labelColor: context.scheme.error,
                        chevronColor: context.scheme.error,
                        onTap: () => _deleteAccount(context),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// صف «تسمية + عنصر تحكّم» بحماية فيض — عكس `AppSectionHeader` يلي
/// بيمرّن الطرفين سوا (مناسب لأيقونة صغيرة)، هون العنصر (شرائح مقسّمة
/// بثلاثة/أربعة خيارات) بده يضل كامل الحجم دائماً لأنه تفاعلي وكل
/// خياراته لازم تبيّن وتنلمس؛ فـ`Flexible` بس حول التسمية (تنقطع بـ
/// ellipsis لو لزم)، والعنصر ياخد حجمه الطبيعي كامل. لو حطينا `Flexible`
/// عالاثنين سوا، Flutter بيقسم المساحة بالتساوي (50/50) بغضّ النظر عن
/// حاجة كل طرف الفعلية، فبينكسر العنصر الأعرض.
class _SettingsControlRow extends StatelessWidget {
  const _SettingsControlRow({required this.label, required this.control});

  final String label;
  final Widget control;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: context.texts.f16W500Black.copyWith(fontSize: 14.5.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        control,
      ],
    );
  }
}

class _AppVersionValue extends StatelessWidget {
  const _AppVersionValue();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final text = info == null ? '—' : '${info.version} (${info.buildNumber})';

        // `TextDirection` وحدها غامضة هون: `easy_localization` بيصدّر
        // `intl.dart` يلي فيه صنف بنفس الاسم — بادئة `ui.` بتفرض نوع
        // dart:ui الصحيح صراحة.
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Text(
            text,
            style: context.texts.f14W400HintColor.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        );
      },
    );
  }
}
