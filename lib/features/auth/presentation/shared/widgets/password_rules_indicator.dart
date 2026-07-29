import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/entities/password_checks.dart';
import 'password_rule_item.dart';

enum PasswordRulesLayout { grid, vertical }

/// بياخد [PasswordChecks] جاهزة بدل `TextEditingController`.
///
/// قبل الهجرة كان بيراقب الـ controller بـ`ValueListenableBuilder`؛ هلق
/// قيمة كلمة المرور موجودة بالحالة، والـ`BlocBuilder` بيعيد البناء أصلاً.
class PasswordRulesIndicator extends StatelessWidget {
  const PasswordRulesIndicator({
    super.key,
    required this.checks,
    this.layout = PasswordRulesLayout.grid,
  });

  final PasswordChecks checks;
  final PasswordRulesLayout layout;

  @override
  Widget build(BuildContext context) {
    return switch (layout) {
      PasswordRulesLayout.grid => _PasswordRulesGrid(checks: checks),
      PasswordRulesLayout.vertical => _PasswordRulesVertical(checks: checks),
    };
  }
}

class _PasswordRulesGrid extends StatelessWidget {
  const _PasswordRulesGrid({required this.checks});

  final PasswordChecks checks;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PasswordRuleItem(
                isValid: checks.hasMinLength,
                text: 'At least 8 characters',
              ),
            ),
            Expanded(
              child: PasswordRuleItem(
                isValid: checks.hasSpecialCharacter,
                text: 'Special character',
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: PasswordRuleItem(
                isValid: checks.hasNumber,
                text: 'At least 1 number (0-9)',
              ),
            ),
            Expanded(
              child: PasswordRuleItem(
                isValid: checks.hasUpperAndLowerCase,
                text: 'Upper & lowercase',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PasswordRulesVertical extends StatelessWidget {
  const _PasswordRulesVertical({required this.checks});

  final PasswordChecks checks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PasswordRuleItem(
          isValid: checks.hasMinLength,
          text: 'At least 8 characters',
        ),
        SizedBox(height: 8.h),
        PasswordRuleItem(
          isValid: checks.hasNumber,
          text: 'At least one number (0-9)',
        ),
        SizedBox(height: 8.h),
        PasswordRuleItem(
          isValid: checks.hasUpperAndLowerCase,
          text: 'At least one uppercase & lowercase letter',
        ),
        SizedBox(height: 8.h),
        PasswordRuleItem(
          isValid: checks.hasSpecialCharacter,
          text: 'One special character such as ! @ # \$',
        ),
      ],
    );
  }
}
