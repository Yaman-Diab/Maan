import 'package:flutter/material.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

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
          style: AppTextStyles.f14W400HintColor,
          children: [
            const TextSpan(text: "Don't have an account? "),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onTap,
                child: Text(
                  'Sign Up',
                  style: AppTextStyles.f15W600Primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
