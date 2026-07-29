import 'package:flutter/material.dart';
import 'package:maan/core/design_system/app_text_styles.dart';

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
          style: AppTextStyles.f14W400HintColor,
          children: [
            const TextSpan(text: 'Where can I find the verification code? '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onTap,
                child: Text(
                  'Click here',
                  style: AppTextStyles.f14W400PrimaryUnderline.copyWith(
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
