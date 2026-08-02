// -------------------------
// Verification Code Scaffold
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/design_system/app_theme_context.dart';

import '../cubit/verification_code_state.dart';
import 'resend_code_section.dart';
import 'verification_code_input.dart';
import 'verification_help_box.dart';
import 'verification_help_link.dart';

/// التخطيط المشترك لشاشات إدخال الرمز.
///
/// بياخد [header] و[submitLabel] كوسائط لأنها الشي الوحيد اللي بيختلف
/// بصرياً بين تأكيد البريد وتأكيد رمز الاستعادة — الباقي (الخانات،
/// العدّاد، الزر، صندوق المساعدة) واحد حرفياً.
///
/// بلا `context.read` لأي Cubit: كل الأفعال بتوصل كـ callbacks، فبيضل
/// قابل للاختبار بلا `BlocProvider` وبيشتغل مع أي من الشاشتين.
class VerificationCodeScaffold extends StatelessWidget {
  const VerificationCodeScaffold({
    super.key,
    required this.state,
    required this.header,
    required this.submitLabel,
    required this.pinController,
    required this.pinFocusNode,
    required this.onCodeChanged,
    required this.onSubmit,
    required this.onResend,
    required this.onToggleHelp,
  });

  final VerificationCodeState state;

  /// ترويسة الشاشة — العنوان والشرح تبع كل تدفّق.
  final Widget header;

  /// نص زر الإرسال بحالته الساكنة وحالة الإرسال.
  final Widget submitLabel;

  final TextEditingController pinController;
  final FocusNode pinFocusNode;

  final ValueChanged<String> onCodeChanged;
  final VoidCallback onSubmit;
  final VoidCallback onResend;
  final VoidCallback onToggleHelp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            children: [
              SizedBox(height: 68.h),

              header,

              SizedBox(height: 38.h),

              VerificationCodeInput(
                controller: pinController,
                focusNode: pinFocusNode,
                length: state.codeLength,
                hasError: state.hasCodeError,
                errorText: state.codeError,
                onChanged: onCodeChanged,
              ),

              SizedBox(height: 34.h),

              ResendCodeSection(
                remainingSeconds: state.remainingSeconds,
                canResend: state.canResend,
                isResending: state.isResending,
                onResendTap: onResend,
              ),

              SizedBox(height: 24.h),

              submitLabel,

              SizedBox(height: 22.h),

              VerificationHelpLink(onTap: onToggleHelp),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: state.isHelpVisible
                    ? Padding(
                        key: const ValueKey('verification-help-box'),
                        padding: EdgeInsets.only(top: 20.h),
                        child: const VerificationHelpBox(),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('verification-help-box-hidden'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
