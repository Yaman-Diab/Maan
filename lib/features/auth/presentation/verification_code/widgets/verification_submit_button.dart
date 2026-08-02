import 'package:flutter/material.dart';
import 'package:maan/core/design_system/widgets/app_button.dart';

/// زر إرسال الرمز. النص بيجي من الشاشة لأن كل تدفّق بيسمّي الفعل بطريقته
/// («تحقّق من البريد الإلكتروني» مقابل «تأكيد الرمز»).
class VerificationSubmitButton extends StatelessWidget {
  const VerificationSubmitButton({
    super.key,
    required this.canSubmit,
    required this.isSubmitting,
    required this.label,
    required this.submittingLabel,
    required this.onPressed,
  });

  final bool canSubmit;
  final bool isSubmitting;
  final String label;
  final String submittingLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !canSubmit,
      child: Opacity(
        opacity: canSubmit ? 1 : 0.45,
        child: AppButton(
          buttonText: isSubmitting ? submittingLabel : label,
          buttonOnPressed: onPressed,
        ),
      ),
    );
  }
}
