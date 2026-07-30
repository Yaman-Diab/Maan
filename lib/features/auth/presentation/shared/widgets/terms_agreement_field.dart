import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

/// مربّع الموافقة على الشروط وسياسة الخصوصية.
///
/// كان في نسختين — وحدة بتسجيل الدخول ووحدة بإنشاء الحساب — اختلفتا
/// بشيئين فقط: مسافة علوية 2px، ومصدر قيمة المربّع. النسخة الموحّدة
/// بتاخد المسافة كوسيط، وبتعتمد [value] كمصدر وحيد للحقيقة.
class TermsAgreementField extends StatelessWidget {
  const TermsAgreementField({
    super.key,
    required this.value,
    required this.onChanged,
    this.onTermsTap,
    this.onPrivacyTap,
    this.textTopPadding = 0,
  });

  /// حالة الموافقة كما بيشوفها الـ Cubit.
  ///
  /// المربّع بيقرأ من هون لا من حالة `FormField` الداخلية: `initialValue`
  /// بتنطبق مرة وحدة عند أول بناء، فلو الـ Cubit صفّر الموافقة لاحقاً
  /// كانت النسخة القديمة تبع تسجيل الدخول تضل معلّمة — عدم تطابق بين
  /// المعروض والحالة الفعلية.
  final bool value;

  final ValueChanged<bool> onChanged;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  /// مسافة علوية للنص لمحاذاته مع المربّع، بوحدات `ScreenUtil`.
  final double textTopPadding;

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: value,
      validator: (value) {
        if (value != true) {
          return 'terms_agreement_error'.tr();
        }

        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: Checkbox(
                    value: value,
                    onChanged: (newValue) {
                      final accepted = newValue ?? false;
                      field.didChange(accepted);
                      onChanged(accepted);
                    },
                    activeColor: context.scheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    side: BorderSide(color: context.scheme.primary, width: 2.w),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: textTopPadding.h),
                    child: RichText(
                      text: TextSpan(
                        style: context.texts.f16W400HintColor,
                        children: [
                          TextSpan(text: 'terms_agreement_prefix'.tr()),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: onTermsTap,
                              child: Text(
                                'terms_and_conditions'.tr(),
                                style: context.texts.f14W400PrimaryUnderline,
                              ),
                            ),
                          ),
                          TextSpan(text: 'terms_agreement_middle'.tr()),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: onPrivacyTap,
                              child: Text(
                                'privacy_policy'.tr(),
                                style: context.texts.f14W400PrimaryUnderline,
                              ),
                            ),
                          ),
                          TextSpan(text: 'terms_agreement_suffix'.tr()),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (field.hasError)
              Padding(
                padding: EdgeInsets.only(left: 34.w, top: 6.h),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: context.scheme.error,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
