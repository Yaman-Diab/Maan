import 'package:flutter/material.dart';
import 'package:maan/core/design_system/app_theme_context.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/di/service_locator.dart';

import '../cubit/sign_up_cubit.dart';
import '../cubit/sign_up_state.dart';
import '../widgets/sign_up_form.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    super.key,
    this.onSignedUp,
    this.onSignInTap,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  /// بتنادى بعد نجاح إنشاء الحساب — الـ backend بيبعت رمز تحقق،
  /// فالمتوقّع الانتقال لشاشة تأكيد البريد.
  final void Function(String email)? onSignedUp;

  final VoidCallback? onSignInTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = SignUpFieldControllers();

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, SignUpState state) {
    switch (state.status) {
      case SignUpStatus.success:
        widget.onSignedUp?.call(state.email);

      case SignUpStatus.failure:
        final message = state.errorMessage;
        if (message == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));

      case SignUpStatus.initial:
      case SignUpStatus.submitting:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpCubit>(
      create: (_) => sl<SignUpCubit>(),
      child: BlocConsumer<SignUpCubit, SignUpState>(
        listener: _onStateChanged,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.colors.pageBackground,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                child: SignUpForm(
                  formKey: _formKey,
                  state: state,
                  controllers: _controllers,
                  onSubmit: () {
                    FocusScope.of(context).unfocus();

                    context.read<SignUpCubit>().submit(
                      isFormValid: () =>
                          _formKey.currentState?.validate() ?? false,
                    );
                  },
                  onSignInTap: widget.onSignInTap,
                  onTermsTap: widget.onTermsTap,
                  onPrivacyTap: widget.onPrivacyTap,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
