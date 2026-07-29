import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'controller/sign_up_controller.dart';
import 'widgets/sign_up_form.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final SignUpController _controller;

  @override
  void initState() {
    super.initState();

    _controller = SignUpController()..addListener(_rebuild);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_rebuild)
      ..dispose();

    super.dispose();
  }

  void _rebuild() {
    if (!mounted) return;

    setState(() {});
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    try {
      await _controller.submit(
        onSubmit: (payload) async {
          // TODO: Call your sign up API / Cubit here.
          // Example:
          // await context.read<AuthCubit>().signUp(payload.toMap());

          debugPrint(payload.toString());
        },
      );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          child: SignUpForm(
            controller: _controller,
            onSubmit: _submit,
            onSignInTap: () {
              // TODO: Navigate to login page.
            },
            onTermsTap: () {
              // TODO: Navigate to Terms page.
            },
            onPrivacyTap: () {
              // TODO: Navigate to Privacy Policy page.
            },
          ),
        ),
      ),
    );
  }
}
