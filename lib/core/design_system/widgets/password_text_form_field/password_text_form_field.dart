import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maan/core/design_system/app_assets.dart';
import 'package:maan/core/design_system/app_theme_context.dart';
import 'package:maan/core/design_system/widgets/custom_text_form_field.dart';
import 'bloc/password_field_cubit.dart';
import 'bloc/password_field_state.dart';

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
          final isHidden = state.isHidden;

          return CustomTextFormField(
            keyBoardType: TextInputType.visiblePassword,
            validationMessage: validationMessage,
            controller: controller,
            onChanged: onChanged,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            suffixIcon: IconButton(
              onPressed: context.read<PasswordFieldCubit>().toggleVisibility,
              icon: isHidden
                  ? SvgPicture.asset(AppAssets.closedEyeIcon)
                  : SvgPicture.asset(
                      AppAssets.openedEyeIcon,
                      colorFilter: ColorFilter.mode(
                        context.scheme.primary,
                        BlendMode.srcIn,
                      ),
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
