// -------------------------
// Home Verification Page
// -------------------------

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maan/core/design_system/app_theme_context.dart';
import 'package:maan/core/design_system/widgets/app_button.dart';
import 'package:maan/core/di/service_locator.dart';
import 'package:maan/core/router/app_routes.dart';
import 'package:maan/core/session/app_session_controller.dart';

/// شاشة رئيسية مؤقّتة **للفحص اليدوي فقط** — لحد ما تُبنى شاشة Home
/// الحقيقية.
///
/// الهدف الوحيد: تأكيد إن تسجيل الدخول اشتغل فعلياً من طرف لطرف —
/// التوكن انحفظ، `AppSessionController` صار `isLoggedIn`، وحالة
/// الحساب (`account_status`) وصلت وانحفظت صح. زر تسجيل الخروج بيفحص
/// المسار العكسي (مسح الجلسة + التوجيه لصفحة الدخول) بنفس الشاشة.
///
/// ملاحظة: ما بتعرض بيانات المستخدم (الاسم/البريد) لأنها مش محفوظة
/// حالياً — راجع `CLAUDE.md`، `AuthUser` بيتبنى وقت الدخول وبينرمى،
/// وما في مصدر حقيقة دائم للمستخدم لسه (`/api/profile` لسه ما انبنت).
class HomeVerificationPage extends StatelessWidget {
  const HomeVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionController = sl<AppSessionController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('login_verification_title'.tr()),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: sessionController,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusRow(
                  label: 'isInitialized',
                  value: sessionController.isInitialized.toString(),
                ),
                _StatusRow(
                  label: 'isLoggedIn',
                  value: sessionController.isLoggedIn.toString(),
                  emphasize: true,
                ),
                _StatusRow(
                  label: 'isGuest',
                  value: sessionController.isGuest.toString(),
                ),
                _StatusRow(
                  label: 'accountStatus',
                  value: sessionController.accountStatus.name,
                  emphasize: true,
                ),
                _StatusRow(
                  label: 'canUseMunicipalityServices',
                  value: sessionController.canUseMunicipalityServices
                      .toString(),
                ),
                SizedBox(height: 32.h),
                if (sessionController.isLoggedIn)
                  AppButton(
                    buttonText: 'logout'.tr(),
                    buttonColor: context.scheme.error,
                    buttonColorSide: context.scheme.error,
                    buttonOnPressed: sessionController.logout,
                  )
                else
                  Text(
                    'guest_session_notice'.tr(),
                    style: context.texts.f14W400HintColor,
                  ),
                SizedBox(height: 12.h),
                // مؤقّت — مدخل «خدمات البلدية» لحد ما تُبنى شاشة Home
                // الحقيقية وتصير هي نقطة الدخول الطبيعية.
                AppButton(
                  buttonText: 'municipal_services_title'.tr(),
                  buttonColor: context.scheme.primary,
                  buttonColorSide: context.scheme.primary,
                  buttonOnPressed: () =>
                      context.push(AppRoutes.municipalServices),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.texts.f14W400HintColor.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: emphasize
                ? context.texts.f16W500Black.copyWith(
                    color: context.scheme.primary,
                    fontWeight: FontWeight.w700,
                  )
                : context.texts.f16W500Black,
          ),
        ],
      ),
    );
  }
}
