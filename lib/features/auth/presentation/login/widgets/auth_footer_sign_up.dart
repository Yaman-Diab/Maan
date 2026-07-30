import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

class AuthFooterSignUp extends StatelessWidget {
  const AuthFooterSignUp({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: context.texts.f14W400HintColor,
          children: [
            TextSpan(text: 'no_account_prompt'.tr()),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onTap,
                child: Text(
                  'sign_up'.tr(),
                  style: context.texts.f15W600Primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
