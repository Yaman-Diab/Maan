import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maan/core/design_system/app_assets.dart';
import 'package:maan/core/design_system/app_colors.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';
import 'bloc/password_field_cubit.dart';
import 'bloc/password_field_states.dart';

class PasswordTextFormField extends StatelessWidget {
  const PasswordTextFormField({
    super.key,
    required this.controller,
    required this.validationMessage,
    this.hintText,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String? Function(String?)? validationMessage;
  final String? hintText;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        return PasswordFieldCubit();
      },
      child: BlocBuilder<PasswordFieldCubit, PasswordFieldState>(
        builder: (BuildContext context, PasswordFieldState state) {
          final passwordCubit = context.read<PasswordFieldCubit>();
          final isHidden = passwordCubit.hiddenPassword;

          return CustomTextFormField(
            keyBoardType: TextInputType.visiblePassword,
            validationMessage: validationMessage,
            controller: controller,
            onChanged: onChanged,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            suffixIcon: IconButton(
              onPressed: () {
                passwordCubit.changeHiddenStatue();
              },
              icon: isHidden
                  ? SvgPicture.asset(AppAssets.closedEyeIcon)
                  : SvgPicture.asset(
                      AppAssets.openedEyeIcon,
                      color: AppColors.primaryColor,
                    ),
            ),
            obscureText: isHidden,
            hintText: hintText,
          );
        },
      ),
    );
  }
}
