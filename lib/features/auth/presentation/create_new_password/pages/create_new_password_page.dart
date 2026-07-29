import 'package:flutter/material.dart';
import 'package:maan/core/design_system/app_theme_context.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maan/core/di/service_locator.dart';

import '../cubit/create_new_password_cubit.dart';
import '../cubit/create_new_password_state.dart';
import '../widgets/create_new_password_form.dart';

class CreateNewPasswordPage extends StatefulWidget {
  const CreateNewPasswordPage({
    super.key,
    required this.email,
    required this.code,
    this.onPasswordChanged,
  });

  /// البريد ورمز التحقق بيجوا من شاشة "نسيت كلمة المرور".
  final String email;
  final String code;

  /// بتنادى بعد نجاح التغيير — المتوقّع الرجوع لتسجيل الدخول.
  final VoidCallback? onPasswordChanged;

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, CreateNewPasswordState state) {
    switch (state.status) {
      case CreateNewPasswordStatus.success:
        widget.onPasswordChanged?.call();

      case CreateNewPasswordStatus.failure:
        final message = state.errorMessage;
        if (message == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));

      case CreateNewPasswordStatus.initial:
      case CreateNewPasswordStatus.submitting:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateNewPasswordCubit>(
      create: (_) => sl<CreateNewPasswordCubit>(
        param1: widget.email,
        param2: widget.code,
      ),
      child: BlocConsumer<CreateNewPasswordCubit, CreateNewPasswordState>(
        listener: _onStateChanged,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.colors.pageBackground,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 24.h,
                      ),
                      child: IntrinsicHeight(
                        child: CreateNewPasswordForm(
                          formKey: _formKey,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          state: state,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
