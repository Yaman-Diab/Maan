import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'controller/create_new_password_controller.dart';
import 'models/create_new_password_payload.dart';
import 'widgets/create_new_password_form.dart';

class CreateNewPasswordPage extends StatefulWidget {
  const CreateNewPasswordPage({
    super.key,
    this.onSubmit,
  });

  final Future<void> Function(CreateNewPasswordPayload payload)? onSubmit;

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  late final CreateNewPasswordController controller;

  @override
  void initState() {
    super.initState();
    controller = CreateNewPasswordController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submit(CreateNewPasswordPayload payload) async {
    if (widget.onSubmit != null) {
      await widget.onSubmit!(payload);
      return;
    }

    // TODO: Call your create new password API / Cubit here.
    // Example:
    // await context.read<AuthCubit>().createNewPassword(payload.toMap());

    debugPrint(payload.toString());
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    try {
      await controller.submit(onSubmit: _submit);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
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
                        controller: controller,
                        onSubmit: _handleSubmit,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
