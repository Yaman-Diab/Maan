import 'package:flutter/material.dart';
import 'package:maan/core/design_system/widgets/app_button.dart';

class CreateNewPasswordSubmitButton extends StatelessWidget {
  const CreateNewPasswordSubmitButton({
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
          buttonText: isSubmitting ? 'Updating...' : 'Update Password',
          buttonOnPressed: onPressed,
        ),
      ),
    );
  }
}
