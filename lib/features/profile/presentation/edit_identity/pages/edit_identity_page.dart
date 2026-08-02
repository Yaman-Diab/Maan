// -------------------------
// Edit Identity Page
// -------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maan/core/di/service_locator.dart';

import '../../../../auth/domain/entities/auth_user.dart';
import '../cubit/edit_identity_cubit.dart';
import '../cubit/edit_identity_state.dart';
import '../widgets/edit_identity_form.dart';

/// شاشة تعديل بيانات الهوية.
///
/// بتوصل بـ`AuthUser` كامل لا حقول لحالها — القيم الحالية بتتعبّى منه
/// مباشرة، وحالة القفل (`isLocked`) بتتحدّد من `accountStatus` تبعه.
///
/// بتقفل نفسها بـ`Navigator.pop(context, true)` عند النجاح — الصفحة
/// الأم (`ProfilePage`) هي يلي بتقرّر شو تعمل بعد الرجوع (إعادة تحميل،
/// رسالة نجاح)، مش هالشاشة.
class EditIdentityPage extends StatefulWidget {
  const EditIdentityPage({super.key, required this.user});

  final AuthUser user;

  @override
  State<EditIdentityPage> createState() => _EditIdentityPageState();
}

class _EditIdentityPageState extends State<EditIdentityPage> {
  final _formKey = GlobalKey<FormState>();
  late final EditIdentityFieldControllers _controllers;

  @override
  void initState() {
    super.initState();

    _controllers = EditIdentityFieldControllers(
      firstName: widget.user.firstName,
      lastName: widget.user.lastName,
      nationalId: widget.user.nationalId ?? '',
      day: widget.user.birthDate?.day,
      month: widget.user.birthDate?.month,
      year: widget.user.birthDate?.year,
    );
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, EditIdentityState state) {
    switch (state.status) {
      case EditIdentityStatus.success:
        Navigator.of(context).pop(true);

      case EditIdentityStatus.failure:
        final message = state.errorMessage;
        if (message == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));

      case EditIdentityStatus.initial:
      case EditIdentityStatus.submitting:
        break;
    }
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();

    context.read<EditIdentityCubit>().submit(
      isFormValid: () => _formKey.currentState?.validate() ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditIdentityCubit>(
      create: (_) => sl<EditIdentityCubit>(param1: widget.user),
      child: BlocConsumer<EditIdentityCubit, EditIdentityState>(
        listener: _onStateChanged,
        builder: (context, state) {
          return EditIdentityForm(
            formKey: _formKey,
            state: state,
            controllers: _controllers,
            onSave: () => _submit(context),
            onCancel: () => Navigator.of(context).pop(false),
          );
        },
      ),
    );
  }
}
