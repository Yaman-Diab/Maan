import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

class AuthFooterSignIn extends StatelessWidget {
  const AuthFooterSignIn({
    super.key,
    this.onSignInTap,
  });

  final VoidCallback? onSignInTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: context.texts.f14W400HintColor,
          children: [
            TextSpan(text: 'already_have_account'.tr()),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onSignInTap,
                child: Text(
                  'sign_in'.tr(),
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
