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
            const TextSpan(text: 'Already have an account? '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onSignInTap,
                child: Text(
                  'Sign in',
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
