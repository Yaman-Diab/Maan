import 'package:flutter/material.dart';
import 'package:maan/core/design_system/widgets/app_button.dart';

/// زر إرسال بحالتَي `canSubmit`/`isSubmitting` — النص بيجي من الشاشة
/// لأن كل تدفّق بيسمّي فعله بطريقته («تحقّق من البريد» مقابل «حفظ
/// التعديلات»).
class AppSubmitButton extends StatelessWidget {
  const AppSubmitButton({
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
