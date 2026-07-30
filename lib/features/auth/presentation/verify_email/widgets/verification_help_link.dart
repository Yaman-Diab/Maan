import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

class VerificationHelpLink extends StatelessWidget {
  const VerificationHelpLink({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: context.texts.f14W400HintColor,
          children: [
            TextSpan(text: 'verification_help_prompt'.tr()),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onTap,
                child: Text(
                  'click_here'.tr(),
                  style: context.texts.f14W400PrimaryUnderline.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
