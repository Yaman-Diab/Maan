import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:maan/core/design_system/widgets/app_button.dart';

class ForgotPasswordSubmitButton extends StatelessWidget {
  const ForgotPasswordSubmitButton({
    super.key,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !canSubmit,
      child: Opacity(
        opacity: canSubmit ? 1 : 0.45,
        child: AppButton(
          buttonText: isSubmitting ? 'sending'.tr() : 'confirm'.tr(),
          buttonOnPressed: onPressed,
        ),
      ),
    );
  }
}
