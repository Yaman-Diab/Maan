import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_colors.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

class LoginTermsAgreementField extends StatelessWidget {
  const LoginTermsAgreementField({
    super.key,
    required this.value,
    required this.onChanged,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: value,
      validator: (value) {
        if (value != true) {
          return 'You must agree to the Terms and Privacy Policy';
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
                    value: field.value ?? false,
                    onChanged: (newValue) {
                      final accepted = newValue ?? false;
                      field.didChange(accepted);
                      onChanged(accepted);
                    },
                    activeColor: AppColors.primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    side: BorderSide(color: AppColors.primaryColor, width: 2.w),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.f16W400HintColor,
                        children: [
                          const TextSpan(text: "I agree with Ma'an "),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: onTermsTap,
                              child: Text(
                                'Terms & Conditions',
                                style: AppTextStyles.f14W400PrimaryUnderline,
                              ),
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: onPrivacyTap,
                              child: Text(
                                'Privacy Policy',
                                style: AppTextStyles.f14W400PrimaryUnderline,
                              ),
                            ),
                          ),
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
                    color: AppColors.errorColor,
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
